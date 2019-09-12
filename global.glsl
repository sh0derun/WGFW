#define NUM_LIGHTS 3

struct Material {
    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
    float shininess;
};

Material emerald 	 	= Material(vec3(0.0215, 0.1745, 0.0215)      ,vec3(0.07568, 0.61424, 0.07568),		vec3(0.633, 0.727811, 0.633),			 0.6);
Material jade			= Material(vec3(0.135, 0.2225, 0.1575)       ,vec3(0.54, 0.89, 0.63),				vec3(0.316228, 0.316228, 0.316228),		 0.1);
Material obsidian		= Material(vec3(0.05375, 0.05, 0.06625)		 ,vec3(0.18275, 0.17, 0.22525),			vec3(0.332741, 0.328634, 0.346435),		 0.3);
Material pearl			= Material(vec3(0.25, 0.20725, 0.20725)		 ,vec3(1.0, 0.829, 0.829),				vec3(0.296648, 0.296648, 0.296648),		 0.088);
Material ruby			= Material(vec3(0.1745, 0.01175, 0.01175)	 ,vec3(0.61424, 0.04136, 0.04136),		vec3(0.727811, 0.626959, 0.626959),		 0.6);
Material turquoise		= Material(vec3(0.1, 0.18725, 0.1745)		 ,vec3(0.396, 0.74151, 0.69102),		vec3(0.297254, 0.30829, 0.306678),		 0.1);
Material bronze			= Material(vec3(0.2125, 0.1275, 0.054),		  vec3(0.714, 0.4284, 0.18144),			vec3(0.393548, 0.271906, 0.166721),		 0.2);
Material chrome			= Material(vec3(0.25, 0.25, 0.25),			  vec3(0.4, 0.4, 0.4),					vec3(0.774597, 0.774597, 0.774597),		 32.0);
Material copper			= Material(vec3(0.19125, 0.0735, 0.0225),	  vec3(0.7038, 0.27048, 0.0828),		vec3(0.256777, 0.137622, 0.086014),		 0.1);
Material gold			= Material(vec3(0.24725, 0.1995, 0.0745),	  vec3(0.75164, 0.60648, 0.22648),		vec3(0.628281, 0.555802, 0.366065),		 0.4);
Material silver			= Material(vec3(0.19225, 0.19225, 0.19225),	  vec3(0.50754, 0.50754, 0.50754),		vec3(0.508273, 0.508273, 0.508273),		 0.4);
Material black_plastic	= Material(vec3(0.0, 0.0, 0.0),				  vec3(0.01, 0.01, 0.01),				vec3(0.50, 0.50, 0.50),					 0.25);
Material cyan_plastic	= Material(vec3(0.0, 0.1, 0.06),			  vec3(0.0, 0.50980392, 0.50980392),	vec3(0.50196078, 0.50196078, 0.50196078),0.25);
Material green_plastic	= Material(vec3(0.0, 0.0, 0.0),				  vec3(0.1, 0.35, 0.1),					vec3(0.45, 0.55, 0.45),					 0.25);
Material red_plastic	= Material(vec3(0.0, 0.0, 0.0),				  vec3(0.5, 0.0, 0.0),					vec3(0.7, 0.6, 0.6),					 0.25);
Material white_plastic  = Material(vec3(0.0, 0.0, 0.0),				  vec3(0.55, 0.55, 0.55),				vec3(0.70, 0.70, 0.70),					 0.25);
Material yellow_plastic = Material(vec3(0.0, 0.0, 0.0),				  vec3(0.5, 0.5, 0.0),					vec3(0.60, 0.60, 0.50),					 0.25);
Material black_rubber   = Material(vec3(0.02, 0.02, 0.02),			  vec3(0.01, 0.01, 0.01),				vec3(0.4, 0.4, 0.4),					 0.078125);
Material cyan_rubber    = Material(vec3(0.0, 0.05, 0.05),			  vec3(0.4, 0.5, 0.5),					vec3(0.04, 0.7, 0.7),					 0.078125);
Material green_rubber	= Material(vec3(0.0, 0.05, 0.0),			  vec3(0.4, 0.5, 0.4),					vec3(0.04, 0.7, 0.04),					 0.078125);
Material red_rubber		= Material(vec3(0.05, 0.0, 0.0),			  vec3(0.5, 0.4, 0.4),					vec3(0.7, 0.04, 0.04),					 0.078125);
Material white_rubber	= Material(vec3(0.05, 0.05, 0.05),			  vec3(0.5, 0.5, 0.5),					vec3(0.7, 0.7, 0.7),					 0.078125);
Material yellow_rubber	= Material(vec3(0.05, 0.05, 0.0),			  vec3(0.5, 0.5, 0.4),					vec3(0.7, 0.7, 0.04),					 0.078125);

    
struct PointLight {
    vec3 position;
    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
    float constant;
    float linear;
    float quadratic;
};

mat2 rot(float a){float c=cos(a),s=sin(a);return mat2(c,-s,s,c);}

float sp(vec3 p, float s){
    return length(p)-s;
}

float pln(vec3 p){
    float freq = 1.2;
    float ph = 0.19*(sin(freq*p.x)+sin(freq*p.z));
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
    for(int i = 0; i < 100; i++){
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
    
    vec3 camPos = vec3(4.0*cos(tm),2.0,4.0*sin(tm));
    vec3 camTar = vec3(0.0,0.0,0.0);
    vec3 camDir = normalize(camTar - camPos);
    vec3 Up = vec3(0.0,1.0,0.0);
    vec3 camRight = normalize(cross(camDir,Up));
    vec3 camUp = cross(camRight, camDir);
    
    vec3 d = normalize(uv.x*camRight + uv.y*camUp + 1.5*camDir);
    
    vec2 t = march(camPos,d);
   
    vec3 col = vec3(0.01)*d.y;
    
    
    if(t.x < 20.0){
        //1.0	0.7	1.8
        PointLight lights[NUM_LIGHTS] = PointLight[NUM_LIGHTS](PointLight(vec3(0.0,2.0,1.0),
                                                                          vec3(0.2,0.2,0.2),
                                                                          vec3(0.5,0.5,0.5),
                                                                          vec3(0.1,0.1,0.1),
                                                                          1.0,0.0014,0.000007),
                                                     		   PointLight(vec3(5.0,3.0,-5.0),
                                                                          vec3(0.3,0.3,0.3),
                                                                          vec3(0.4,0.4,0.4),
                                                                          vec3(0.3,0.3,0.3),
                                                                          1.0,0.0014,0.000007),
                                                     		   PointLight(vec3(4.0,4.0,3.0),
                                                                          vec3(0.1,0.1,0.1),
                                                                          vec3(0.8,0.8,0.8),
                                                                          vec3(0.6,0.6,0.6),
                                                                          1.0,0.0014,0.000007));
        
        for(int i = 0; i < NUM_LIGHTS; i++){
            vec3 p = camPos+t.x*d;
            vec3 nr = normal(p);
            vec3 light_dir = normalize(lights[i].position - p);
            float light_shadow = smoothstep(march(p+nr*0.001, light_dir).x,0.0,1.0);

            float diff = clamp(dot(nr,light_dir),0.0,1.0);

            vec3 viewDir = normalize(camPos - p);
            vec3 reflectDir = reflect(-light_dir, nr);
            float spec = 0.0;
            
            vec3 z = vec3(0.0);
            Material material;

            if(t.y == 1.0){
                float f = smoothstep(0.2,0.1,sin(18.0*p.x)+sin(18.0*p.z)+sin(18.0*p.y));
                material = silver;
                material.diffuse *= f;
                material.shininess *= 64.0;
            }
            else if(t.y == 2.0){
                float f = smoothstep(0.2,0.1,sin(18.0*p.x)+sin(18.0*p.z));
                material = ruby;
                material.diffuse *= f;
                material.shininess *= 10.0;
            }
            
            vec3 ambient = lights[i].ambient * material.ambient;
            vec3 diffuse = lights[i].diffuse * (diff * material.diffuse) * softshadow(p,light_dir,0.01, 3.0, 32.0);
            
            //gamma correction
            float gamma = 1.1;
			diffuse = pow(diffuse, vec3(gamma));
            
            if(true){
                vec3 halfwayDir = normalize(light_dir + viewDir);
                spec = pow(max(dot(nr, halfwayDir), 0.0), material.shininess);
            }
            else{
                vec3 reflectDir = reflect(-light_dir, nr);
                spec = pow(max(dot(viewDir, reflectDir), 0.0), material.shininess);
            }
            
            vec3 specular = lights[i].specular * (spec * material.specular);
            
            float dist = length(lights[i].position - vec3(uv,0.0));
			float attenuation = 1.0 / (lights[i].constant + lights[i].linear * dist + lights[i].quadratic * (dist * dist));
            
            ambient *= attenuation;
            diffuse *= attenuation;
            specular *= attenuation;
            
            col += ambient + diffuse + specular;
        }
        
    }
    
    fragColor = vec4(col,1.0);
}