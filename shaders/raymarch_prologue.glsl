mat2 rot(float a){float c=cos(a),s=sin(a);return mat2(c,-s,s,c);}

float vmax(vec3 v){return max(v.x,max(v.y,v.z));}

float box(vec3 p, vec3 s){return vmax(abs(p)-s);}

float sp(vec3 p, float s){
    return length(p)-s;
}

float pln(vec3 p){
    float freq = 1.1;
    float ph = 0.19*(sin(freq*p.x)+sin(freq*p.z));
    return p.y + ph + speed;
}

float ceiling(vec3 p){
    return -p.y + 4.11;
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

vec2 wierdObject(vec3 p){
    float r = 0.5;
    rotateZ(p,PI/2.0);
    return vec2(sminCubic(fCylinder(p-vec3(0.0,1.0,-3.0),0.2,1.3),sp(p-vec3(0.0,1.0,-3.0),r),1.0),1.0);
}

vec2 regularObject(vec3 p){
    return vec2(box(p-vec3(0.0,1.0,1.5),vec3(0.5)),3.0);
}

vec2 sceneObjects(vec3 p){
    vec2 obj1 = wierdObject(p);
    vec2 obj2 = regularObject(p);
    return (obj2.x < obj1.x) ? obj2 : obj1;
}

vec2 walls(vec3 p){
    vec2 floor = vec2(pln(p),2.0);
    vec2 ceiling = vec2(ceiling(p),2.0);
    vec2 res = (floor.x < ceiling.x) ? floor : ceiling;
    float dist = -(max(abs(p.x),abs(p.z))-9.0);
    vec2 bounds = vec2(dist,4.0);
    res = (res.x < bounds.x) ? res : bounds;
    return res;
}

vec2 sdf(vec3 p){
    vec2 objects = sceneObjects(p);
    vec2 resWalls = walls(p);
    return (objects.x < resWalls.x) ? objects : resWalls;
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

float marchOverrelaxation(vec3 o, vec3 d, float t_min, float t_max, float pixelRadius, bool forceHit){
    float omega = 1.2;
    float t = t_min;
    float candidate_error = 999999.0;
    float candidate_t = t_min;
    float previousRadius = 0.0;
    float stepLength = 0.0;
    float functionSign = sdf(o).x < 0.0 ? -1.0 : +1.0;
    for (int i = 0; i < 80; ++i) {
        float signedRadius = functionSign * sdf(d*t + o).x;
        float radius = abs(signedRadius);
        bool sorFail = omega > 1.0 && (radius + previousRadius) < stepLength;
        if (sorFail) {
            stepLength -= omega * stepLength;
            omega = 1.0;
        } 
        else {
            stepLength = signedRadius * omega;
        }
        previousRadius = radius;
        float error = radius / t;
        if (!sorFail && error < candidate_error) {
            candidate_t = t;
            candidate_error = error;
        }
        if (!sorFail && error < pixelRadius || t > t_max)
            break;
        t += stepLength;
    }
    if ((t > t_max || candidate_error > pixelRadius) && !forceHit) return 999999.0;
    return candidate_t;
}