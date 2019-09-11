#define NUM_LIGHTS 3

struct Material {
    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
    float shininess;
};
    
float random (vec2 st) {
    return fract(sin(dot(st.xy,vec2(12.9898,78.233)))*43758.5453123);
}

mat2 rot(float a){float c=cos(a),s=sin(a);return mat2(c,-s,s,c);}

float sp(vec3 p, float s){
    return length(p)-s;
}

float pln(vec3 p){
    float freq = 5.0;
    float ph = 0.9+0.07*(sin(freq*p.x)+sin(freq*p.z));
    return p.y + ph;
}

float fCylinder(vec3 p, float r, float height) {
	float d = length(p.xz) - r;
	d = max(d, abs(p.y) - height);
	return d;
}

void rotateX(inout vec3 p, float a){p.yz *= rot(a);}
void rotateY(inout vec3 p, float a){p.xz *= rot(a);}
void rotateZ(inout vec3 p, float a){p.xy *= rot(a);}

float sminCubic( float a, float b, float k ){
    float h = max( k-abs(a-b), 0.0 )/k;
    return min( a, b ) - h*h*h*k*(1.0/6.0);
}

vec2 obj(vec3 p){
    p.y -= 0.5;
    rotateZ(p,3.1415965/2.0);
    return vec2(sminCubic(fCylinder(p,0.2,1.3),sp(p,0.6),1.0),1.0);
}

vec2 sdf(vec3 p){
    vec2 a = obj(p);
    vec2 b = vec2(pln(p),2.0);
    return (b.x < a.x) ? b : a;
}

vec2 march(vec3 o, vec3 d){
    vec2 t = vec2(0.0);
    for(int i = 0; i < 150; i++){
    	vec3 p = o + t.x*d;
        vec2 d = sdf(p);
        if(d.x < 0.001) break;
        t.x += d.x;
        t.y = d.y;
        if(t.x > 20.0) break;
    }
    return t;
}

vec3 normal(vec3 p){
    vec2 e = vec2(0.0001, 0.0);
    float dx = sdf(p+e.xyy).x-sdf(p-e.xyy).x;
    float dy = sdf(p+e.yxy).x-sdf(p-e.yxy).x;
    float dz = sdf(p+e.yyx).x-sdf(p-e.yyx).x;
    return normalize(vec3(dx,dy,dz));
}

float shadow( in vec3 ro, in vec3 rd, float mint, float maxt ){
    for( float t=mint; t<maxt; ){
        float h = sdf(ro + rd*t).x;
        if( h<0.001 )
            return 0.0;
        t += h;
    }
    return 1.0;
}

float softshadow( in vec3 ro, in vec3 rd, float mint, float maxt, float k )
{
    float res = 1.0;
    float ph = 1e20;
    for( float t=mint; t<maxt; )
    {
        float h = sdf(ro + rd*t).x;
        if( h<0.001 )
            return 0.0;
        float y = h*h/(2.0*ph);
        float d = sqrt(h*h-y*y);
        res = min( res, k*d/max(0.0,t-y) );
        ph = h;
        t += h;
    }
    return res;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord/iResolution.xy*2.0-1.0;
    uv.x *= iResolution.x/iResolution.y;
	
    float tm = iTime * 0.3;
    
    vec3 camPos = vec3(3.0*cos(tm),1.0,3.0*sin(tm));
    vec3 camTar = vec3(0.0,0.0,0.0);
    vec3 camDir = normalize(camTar - camPos);
    vec3 Up = vec3(0.0,1.0,0.0);
    vec3 camRight = normalize(cross(camDir,Up));
    vec3 camUp = cross(camRight, camDir);
    
    vec3 d = normalize(uv.x*camRight + uv.y*camUp + 1.5*camDir);
    
    vec2 t = march(camPos,d);
    
    //vec3 col = vec3(0.4,0.7,.9)+d.y;
	//col = mix(col, vec3(0.7,0.7,0.8),exp(d.y*2.0));
    vec3 col = vec3(0.2,0.5,.7)+d.y;
    col = mix(col, vec3(0.5),exp(d.y));
    
    if(t.x < 20.0){
        
        vec3 lightColors[NUM_LIGHTS] = vec3[NUM_LIGHTS](vec3(0.8,0.0,0.0),
                                                        vec3(0.0,0.6,0.0),
                                                        vec3(0.0,0.0,0.9));
        vec3 lightPos[NUM_LIGHTS] = vec3[NUM_LIGHTS](vec3(0.0,2.0,1.0),
                                                     vec3(5.0,3.0,-5.0),
                                                     vec3(4.0,4.0,4.0));
        for(int i = 0; i < NUM_LIGHTS; i++){
            vec3 p = camPos+t.x*d;
            vec3 nr = normal(p);
            vec3 light_dir = normalize(lightPos[i] - p);
            float light_shadow = smoothstep(march(p+nr*0.001, light_dir).x,0.0,1.0);
            //float light_shadow = step(march(p+nr*0.001, light_dir).x,0.0);

            float diff = clamp(dot(nr,light_dir),-1.0,1.0);

            float specularStrength = 0.5;
            vec3 viewDir = normalize(camPos - p);
            vec3 reflectDir = reflect(-light_dir, nr);
            float spec = 0.0;
            
            vec3 z = vec3(0.0);
            Material material;

            if(t.y == 1.0){
                //col += lightColors[i]*(diff+ambient+spec)*light_shadow;
                float f = smoothstep(0.2,0.1,sin(18.0*p.x)+sin(18.0*p.z)+sin(18.0*p.y));
                material = Material(vec3(1.0, 0.5, 0.31)*f,
                                    vec3(1.0, 0.5, 0.31),
                                    vec3(0.5, 0.5, 0.5),
                                    32.0);
                z = vec3(0.7,0.3,0.9);
            }
            else if(t.y == 2.0){
                float f = smoothstep(0.2,0.1,sin(18.0*p.x)+sin(18.0*p.z));
                z = vec3(0.3,0.5*f,0.7);
                
                material = Material(vec3(0.5, 1.0, 0.31)*f,
                                    vec3(0.5, 1.0, 0.31),
                                    vec3(0.5, 0.5, 0.5),
                                    64.0);
            }
            
            vec3 ambient = lightColors[i] * material.ambient;
            vec3 diffuse = lightColors[i] * (diff * material.diffuse) * softshadow(p,light_dir,0.01, 3.0, 32.0);
            
            if(false){
                vec3 halfwayDir = normalize(light_dir + viewDir);
                spec = pow(max(dot(nr, halfwayDir), 0.0), material.shininess);
            }
            else{
                vec3 reflectDir = reflect(-light_dir, nr);
                spec = pow(max(dot(viewDir, reflectDir), 0.0), material.shininess);
            }
            
            vec3 specular = lightColors[i] * (spec * material.specular);
            
            col += ambient + diffuse + specular;
        }
        
    }
    
    fragColor = vec4(col,1.0);
}