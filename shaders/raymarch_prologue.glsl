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