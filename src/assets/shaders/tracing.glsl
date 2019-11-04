#version 300 es

#ifdef GL_ES
precision mediump float;
#endif

#include<uniforms.glsl>

out vec4 outColor;

#include<constants.glsl>
#include<material.glsl>
#include<light.glsl>

#include<raymarch_prologue.glsl>

vec3 O, D, P, N;

float mcd = 0.5;
float mshi = 100.0;
vec3 mc = vec3(1.0);

float dirlight(vec3 ld){
    return mcd * max(0.0, dot(N, ld)) / PI + (1.0 - mcd) * (mshi + 8.0) / (8.0 * PI) * pow(max(0.0, dot(N, normalize(ld - D))), mshi);
}

void main( void ){
    vec2 uv = (gl_FragCoord.xy / resolution)*2.0-1.0;
    uv.x *= resolution.x/resolution.y;

    float tm = time;
    O = vec3(camera.x*cos(tm),camera.y,camera.z*sin(tm))+1.5*sin(tm)*vec3(2.0*noise(tm*1.4),0.0,2.0*noise(tm*1.4));
    //O = vec3(0.0,2.0,4.0);
    vec3 camTar = vec3(0.0,0.0,0.0);
    vec3 camDir = normalize(camTar - O);
    vec3 Up = vec3(0.0,1.0,0.0);
    vec3 camRight = normalize(cross(camDir,Up));
    vec3 camUp = cross(camRight, camDir);
            
    D = normalize(uv.x*camRight + uv.y*camUp + 1.5*camDir);
    //D = normalize(vec3(uv,-1.0));

    //vec3 col = vec3(uv,0.0);
    vec3 col = E.xxx, kc = E.zzz;
    //vec3 t = march(O, D, 100);
    //float t = tr(O, D, 20.0*speed);
    for(int i = 0; i < 2; i++){
        vec3 t = march(O, D, 100);
        P = O + D * t.x;
        N = normal(P);
        col += kc * vec3(1.0)*dirlight(normalize(vec3(1.0)))*vec3(0.3,0.3,0.9);
        col += kc * vec3(1.0)*dirlight(normalize(vec3(-1.0,1.0,1.0)))*vec3(0.8,0.3,0.1);
        O = P + D * 2.0* speed;
                //O = P + D * 0.01;
                D = refract(D, N, 1.0/1.333);
    }
    outColor = vec4(sqrt(col),1.0);
}
