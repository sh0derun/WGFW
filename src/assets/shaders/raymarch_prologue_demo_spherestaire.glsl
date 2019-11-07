#define saturate(x) (clamp((x), 0.0, 1.0))

float hash( float n ){return fract(sin(n)*758.5453);}
float hash(vec2 p) {vec3 p3 = fract(vec3(p.xyx) * 0.13); p3 += dot(p3, p3.yzx + 3.333); return fract((p3.x + p3.y) * p3.z); }
float noise(float x) { float i = floor(x); float f = fract(x); float u = f * f * (3.0 - 2.0 * f); return mix(hash(i), hash(i + 1.0), u); }
float noise(vec2 x) { vec2 i = floor(x); vec2 f = fract(x); float a = hash(i); float b = hash(i + vec2(1.0, 0.0)); float c = hash(i + vec2(0.0, 1.0)); float d = hash(i + vec2(1.0, 1.0)); vec2 u = f * f * (3.0 - 2.0 * f); return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y; }

const mat3 m = mat3( 0.00,  0.80,  0.60,
                    -0.80,  0.36, -0.48,
                    -0.60, -0.48,  0.64 );

vec3 hash( vec3 p ) // replace this by something better
{
    p = vec3( dot(p,vec3(127.1,311.7, 74.7)),
              dot(p,vec3(269.5,183.3,246.1)),
              dot(p,vec3(113.5,271.9,124.6)));

    return -1.0 + 2.0*fract(sin(p)*43758.5453123);
}

float noise( in vec3 p )
{
    vec3 i = floor( p );
    vec3 f = fract( p );
    
    vec3 u = f*f*(3.0-2.0*f);

    return mix( mix( mix( dot( hash( i + vec3(0.0,0.0,0.0) ), f - vec3(0.0,0.0,0.0) ), 
                          dot( hash( i + vec3(1.0,0.0,0.0) ), f - vec3(1.0,0.0,0.0) ), u.x),
                     mix( dot( hash( i + vec3(0.0,1.0,0.0) ), f - vec3(0.0,1.0,0.0) ), 
                          dot( hash( i + vec3(1.0,1.0,0.0) ), f - vec3(1.0,1.0,0.0) ), u.x), u.y),
                mix( mix( dot( hash( i + vec3(0.0,0.0,1.0) ), f - vec3(0.0,0.0,1.0) ), 
                          dot( hash( i + vec3(1.0,0.0,1.0) ), f - vec3(1.0,0.0,1.0) ), u.x),
                     mix( dot( hash( i + vec3(0.0,1.0,1.0) ), f - vec3(0.0,1.0,1.0) ), 
                          dot( hash( i + vec3(1.0,1.0,1.0) ), f - vec3(1.0,1.0,1.0) ), u.x), u.y), u.z );
}

float fbm(vec3 p){
    float f  = 0.5000*noise( p ); p = m*p*2.01;
    f += 0.2500*noise( p ); p = m*p*2.02;
    f += 0.1250*noise( p ); p = m*p*2.03;
    f += 0.0625*noise( p ); p = m*p*2.01;
    return smoothstep( -0.7, 0.7, f );
}


mat2 rot(float a){float c=cos(a),s=sin(a);return mat2(c,-s,s,c);}

float vmax(vec3 v){return max(v.x,max(v.y,v.z));}

void rep3(inout vec3 p, vec3 rep){
    p = mod(p+0.5*rep,rep)-0.5*rep;
}

void rep3bound(inout vec3 p, in float rep, in vec3 l){
    p = p-rep*clamp(round(p/rep),-l,l);
}

float box(vec3 p, vec3 s){return vmax(abs(p)-s);}

float rbox(vec3 p, vec3 s, float r){
    vec3 q = abs(p)-s;
    return length(max(q,0.0))-r;
}

float sp(vec3 p, float s){
    return length(p)-s;
}

float pln(vec3 p){
    float freq = 1.1;
    float ph = 0.19;//*(sin(freq*p.x)+sin(freq*p.z));
    return p.y + ph;
}

float ceiling(vec3 p){
    return -p.y + 4.11;
}

float fCylinder(vec3 p, float r, float height) {
	float d = length(p.xz) - r;
	d = max(d, abs(p.y) - height);
	return d;
}

float torus(vec3 p, float r1, float r2){
    float distCircle = length(p.xz)-r1;
    vec2 internalTorus = vec2(distCircle, p.y);
    float distTorus = length(internalTorus)-r2;
    return distTorus;
}

mat3 rotateX(float a){float c=cos(a),s=sin(a); return mat3(1,0,0,0,c,-s,0,s,c);}
mat3 rotateY(float a){float c=cos(a),s=sin(a); return mat3(c,0,-s,0,1,0,s,0,c);}
mat3 rotateZ(float a){float c=cos(a),s=sin(a); return mat3(c,-s,0,s,c,0,0,0,1);}

float sminCubic( float a, float b, float k ){
    float h = max( k-abs(a-b), 0.0 )/k;
    return min( a, b ) - h*h*h*k*(1.0/6.0);
}

vec2 opBlend(vec2 d1, vec2 d2){
    float k = 2.0;
    float d = sminCubic(d1.x, d2.x, k);
    float m = mix(d1.y, d2.y, clamp(d1.x-d,0.0,1.0));
    return vec2(d, m);
}

float tick(float t){
    float a = floor(t);
    float b = fract(t);
    b = smoothstep(0.0,1.0,b);
    b = smoothstep(0.0,0.0,b);
    return a+b;
}

float fHexagonCircumcircle(vec3 p, vec2 h) {
    vec3 q = abs(p);
    return max(q.y - h.y, max(q.x*sqrt(3.0)*0.5 + q.z*0.5, q.z) - h.x);
    //this is mathematically equivalent to this line, but less efficient:
    //return max(q.y - h.y, max(dot(vec2(cos(PI/3), sin(PI/3)), q.zx), q.z) - h.x);
}

// Repeat in two dimensions
vec2 pMod2(inout vec2 p, vec2 size) {
    vec2 c = floor((p + size*0.5)/size);
    p = mod(p + size*0.5,size) - size*0.5;
    return c;
}

float pModInterval1(inout float p, float size, float start, float stop) {
    float halfsize = size*0.5;
    float c = floor((p + halfsize)/size);
    p = mod(p+halfsize, size) - halfsize;
    if (c > stop) { //yes, this might not be the best thing numerically.
        p += size*(c - stop);
        c = stop;
    }
    if (c <start) {
        p += size*(c - start);
        c = start;
    }
    return c;
}

/*float pModInterval2(inout vec2 p, vec2 size, vec2 start, vec2 stop) {
    vec2 halfsize = size*0.5;
    float c = floor((p + halfsize)/size);
    p = mod(p+halfsize, size) - halfsize;
    if (c > stop) { //yes, this might not be the best thing numerically.
        p += size*(c - stop);
        c = stop;
    }
    if (c <start) {
        p += size*(c - start);
        c = start;
    }
    return c;
}*/

vec2 sdf(vec3 p){
    vec3 q = p;
    q *= rotateY(time);
    vec2 sphere = vec2(sp(q, 4.0),1.0);
    float mountain = clamp(1.0 - noise(q * /*(sin(time)*0.5+0.5)*/ 2.5) + (max(abs(q.y) - 1.0, 0.0)) * 0.03, 0.0, 1.0);
    mountain = (mountain*mountain*mountain) * 0.25 + 0.8;
    sphere.x += mountain;
    sphere.x *= 0.6;

    vec2 outSphere = vec2(sp(p, 3.7),2.0);
    outSphere.x = abs(outSphere.x)+0.35;
    outSphere.x += noise(p * /*(sin(time)*0.5+0.5)*/ 1.52 + time*0.75);
    outSphere.x *= 0.6;

    vec2 resSphere = sphere.x < outSphere.x ? sphere : outSphere;

    return resSphere;
}

vec3 march(vec3 o, vec3 d, int maxIteration){
    vec2 t = vec2(0.0);
    float iter = 0.0;
    for(int i = 0; i < maxIteration; i++){
        iter = float(i)/float(maxIteration);
    	vec3 p = o + t.x*d;
        vec2 d = sdf(p);
        t.x += d.x;
        t.y = d.y;
        if(t.x > 20.0 || abs(d.x) < (0.001*t.x)) break;
    }
    return vec3(t,iter);
}

float tr(vec3 o, vec3 d, float Ml){
    float l = 0.0;
    for(int i = 0; i < 100; i++){
        vec3 p = o + d * l;
        float dd = sdf(p).x;
        l += dd;
        if(dd < 0.001)break;
    }
    return l;
}

vec3 normal(vec3 p){
    vec2 e = vec2(0.0001, 0.0);
    float dx = sdf(p+e.xyy).x-sdf(p-e.xyy).x;
    float dy = sdf(p+e.yxy).x-sdf(p-e.yxy).x;
    float dz = sdf(p+e.yyx).x-sdf(p-e.yyx).x;
    return normalize(vec3(dx,dy,dz));
}

const vec3 E = vec3(0.0,0.001,1.0);

vec3 nn(vec3 p){
    return normalize(vec3(sdf(p+E.yxx).x,sdf(p+E.xyx).x,sdf(p+E.xxy).x)-sdf(p).x);
}

vec3 nrml(vec3 p){
    float epsilon = 0.001; // arbitrary — should be smaller than any surface detail in your distance function, but not so small as to get lost in float precision
    float centerDistance = sdf(p).x;
    float xDistance = sdf(p + vec3(epsilon, 0, 0)).x;
    float yDistance = sdf(p + vec3(0, epsilon, 0)).x;
    float zDistance = sdf(p + vec3(0, 0, epsilon)).x;
    vec3 normal = (vec3(xDistance, yDistance, zDistance) - centerDistance) / epsilon;
    return normal;
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
        if( h<0.0001 )
            return 0.0;
        float y = h*h/(2.0*ph);
        float d = sqrt(h*h-y*y);
        res = min( res, k*d/max(0.0,t-y) );
        ph = h;
        t += h;
    }
    return res;
}

vec2 marchOverrelaxation(vec3 o, vec3 d, float t_min, float t_max, float pixelRadius, bool forceHit){
    float omega = 1.2;
    float t = t_min;
    float candidate_error = INFINITY;
    vec2 candidate_t = vec2(t_min,0.0);
    float previousRadius = 0.0;
    float stepLength = 0.0;
    float functionSign = sdf(o).x < 0.0 ? -1.0 : +1.0;
    for (int i = 0; i < 80; ++i) {
        vec2 sdfResult = sdf(d*t + o);
        float signedRadius = functionSign * sdfResult.x;
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
            candidate_t = vec2(t,sdfResult.y);
            candidate_error = error;
        }
        if (!sorFail && error < pixelRadius || t > t_max)
            break;
        t += stepLength;
    }
    //if ((t > t_max || candidate_error > pixelRadius) && !forceHit) return vec2(INFINITY,0.0);
    if(t <= t_max && candidate_error <= pixelRadius)    return candidate_t;
}

float calcAO( in vec3 pos, in vec3 nor ){
    float occ = 0.0;
    float sca = 1.0;
    for( int i=0; i<4; i++ )
    {
        float hr = 0.01 + 0.12*float(i)/4.0;
        vec3 aopos =  nor * hr + pos;
        float dd = sdf( aopos ).x;
        occ += -(dd-hr)*sca;
        sca *= 0.95;
    }
    return clamp( 1.0 - 3.0*occ, 0.0, 1.0 ) * (0.5+0.5*nor.y);
}
