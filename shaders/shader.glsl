#version 330 core

out vec4 fragColor;

#include "material.glsl"
#include "light.glsl"
#include "raymarchPrologue.glsl"

#define NUM_LIGHTS 3

void main(void){
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