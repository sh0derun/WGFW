#define saturate(x) (clamp((x), 0.0, 1.0))
#define gammacorrect(col, x) pow(col, vec3(1.0/x))

float hash( float n ){return fract(sin(n)*758.5453);}
float hash(vec2 p) {vec3 p3 = fract(vec3(p.xyx) * 0.13); p3 += dot(p3, p3.yzx + 3.333); return fract((p3.x + p3.y) * p3.z); }
float noise(float x) { float i = floor(x); float f = fract(x); float u = f * f * (3.0 - 2.0 * f); return mix(hash(i), hash(i + 1.0), u); }
float noise(vec2 x) { vec2 i = floor(x); vec2 f = fract(x); float a = hash(i); float b = hash(i + vec2(1.0, 0.0)); float c = hash(i + vec2(0.0, 1.0)); float d = hash(i + vec2(1.0, 1.0)); vec2 u = f * f * (3.0 - 2.0 * f); return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y; }

mat2 rot(float a){float c=cos(a),s=sin(a);return mat2(c,-s,s,c);}

float vmax(vec3 v){return max(v.x,max(v.y,v.z));}

float box(vec3 p, vec3 s){return vmax(abs(p)-s);}

float rbox(vec3 p, vec3 s, float r){
    vec3 q = abs(p)-s;
    return length(max(q,0.0))-r;
}

float sp(vec3 p, float s){
    return length(p)-s;
}

float pln(vec3 p, float h){
    float freq = 3.0;
    float ph = 0.19+h;
    //float ph = 0.5*noise(freq*p.xzx)+h;
    return p.y + ph;
}

float pln(vec3 p){
    float freq = 1.1;
    float ph = 0.19;//*(sin(freq*p.x)+sin(freq*p.z));
    return p.y + ph;
}

mat3 rotateX(float a){float c=cos(a),s=sin(a); return mat3(1,0,0,0,c,-s,0,s,c);}
mat3 rotateY(float a){float c=cos(a),s=sin(a); return mat3(c,0,-s,0,1,0,s,0,c);}
mat3 rotateZ(float a){float c=cos(a),s=sin(a); return mat3(c,-s,0,s,c,0,0,0,1);}

float sminCubic( float a, float b, float k ){
    float h = max( k-abs(a-b), 0.0 )/k;
    return min( a, b ) - h*h*h*k*(1.0/6.0);
}

vec2 sminCubic( vec2 a, vec2 b, float k ){
    vec2 h = max( k-abs(a-b), 0.0 )/k;
    return min( a, b ) - h*h*h*k*(1.0/6.0);
}

vec2 opBlend(vec2 d1, vec2 d2){
    float k = 2.0;
    float d = sminCubic(d1.x, d2.x, k);
    float m = mix(d1.y, d2.y, clamp(d1.x-d,0.0,1.0));
    return vec2(d, m);
}

SdfPhongResult sdf(vec3 p, vec2 uv){
    vec3 q = p;
    q -= vec3(0.0,1.0,0.0);
    float ns = noise(q.xz*1.5) * 1.049;
    //float freq = 9.0;
    //float f = 3.0*smoothstep(0.0,4.0,pow(ns*-1.5*sin(freq*q.x)*sin(q.y*freq)*sin(q.z*freq),2.0));
    /*SdfPhongResult sphere = SdfPhongResult((max(abs(sp(q, 2.0))-0.07,
                                           dot(q, normalize(vec3(0.0,-1.0,0.0)))+ns*mix(0.0,1.0,smoothstep(-1.0,0.61,sin(q.z*2.0)*sin(q.x*2.0)*0.43)))-(0.02*f)) * 0.6, 
                                           mixMaterial(gold, ruby, nsm));*/
    SdfPhongResult sphere = SdfPhongResult(sp(q, 2.0), mixMaterial(gold, ruby, ns));

    sphere.m.shininess *= 200.0;
    return sphere;
}

vec3 triplanarMap(vec3 surfacePos, vec3 normal, sampler2D tex, float scale){
    mat3 triMapSamples = mat3(
        texture(tex, surfacePos.yz * scale).rgb,
        texture(tex, surfacePos.xz * scale).rgb,
        texture(tex, surfacePos.xy * scale).rgb
        );
    return triMapSamples * abs(normal);
}

SdfPhongResult march(vec3 ro, vec3 rd, vec2 uv, int maxIteration){
    SdfPhongResult t = SdfPhongResult(0.0, silver);
    float iter = 0.0;
    for(int i = 0; i < maxIteration; i++){
        iter = float(i)/float(maxIteration);
    	vec3 p = ro + t.d*rd;
        SdfPhongResult d = sdf(p, uv);
        t.d += d.d;
        t.m = d.m;
        if(t.d > MAX_DIST || abs(d.d) < (0.001*t.d)) break;
        //if(d.x < 0.001) break;
    }
    return t;
}

vec3 normal(vec3 p){
    vec2 e = vec2(0.0001, 0.0);
    float dx = sdf(p+e.xyy,e).d-sdf(p-e.xyy,e).d;
    float dy = sdf(p+e.yxy,e).d-sdf(p-e.yxy,e).d;
    float dz = sdf(p+e.yyx,e).d-sdf(p-e.yyx,e).d;
    return normalize(vec3(dx,dy,dz));
}

const vec3 E = vec3(0.0,0.001,1.0);

vec2 marchOverrelaxation(vec3 o, vec3 d, float t_min, float t_max, float pixelRadius, bool forceHit){
    /*float omega = 1.2;
    float t = t_min;
    float candidate_error = INFINITY;
    vec2 candidate_t = vec2(t_min,0.0);
    float previousRadius = 0.0;
    float stepLength = 0.0;
    float functionSign = sdf(o).d < 0.0 ? -1.0 : +1.0;
    for (int i = 0; i < 80; ++i) {
        vec2 sdfResult = sdf(d*t + o);
        float signedRadius = functionSign * sdfResult.d;
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
    if(t <= t_max && candidate_error <= pixelRadius)    return candidate_t;*/
    return vec2(1.0);
}

float calcAO( in vec3 pos, in vec3 nor ){
    float occ = 0.0;
    float sca = 1.0;
    for( int i=0; i<uao.depth; i++ ){
        vec3 aopos =  nor * (0.2*float(i)/4.0) + pos;
        float dd = sdf( aopos , aopos.xy).d;
        occ += -(dd-(0.2*float(i)/4.0))*sca;
        sca *= 0.95;
    }
    return clamp( 1.0 - 3.0*occ, 0.0, 1.0 ) * (0.5+0.5*nor.y);
}
