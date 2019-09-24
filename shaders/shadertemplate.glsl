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

void main( void ){
    vec2 uv = gl_FragCoord.xy / resolution*2.0-1.0;
    uv.x *= resolution.x/resolution.y;
	
    float tm = time*speed;
    
    vec3 camPos = vec3(camera.x,camera.y,camera.z);
    vec3 camTar = vec3(mouse.x,mouse.y,0.0);
    vec3 camDir = normalize(camTar - camPos);
    vec3 Up = vec3(0.0,1.0,0.0);
    vec3 camRight = normalize(cross(camDir,Up));
    vec3 camUp = cross(camRight, camDir);
    
    vec3 d = normalize(uv.x*camRight + uv.y*camUp + 1.5*camDir);
    vec2 t = vec2(0.0);
    if(!overRelaxation){
        t = march(camPos,d);
    }
    else{
        t = marchOverrelaxation(camPos, d, 0.001, 20.0, 0.001, true);
    }
    vec3 col = vec3(0.0);
    
    if(t.x < 20.0){
        PointLight lights[NUM_LIGHTS];
        lights[0] = PointLight(vec3(2.0,2.0,0.0),vec3(0.4,0.4,0.4),vec3(0.5,0.5,0.5),vec3(0.2,0.2,0.2),1.0,0.0014,0.000007);
        lights[1] = PointLight(vec3(0.0,5.0,-3.0),vec3(0.3,0.3,0.3),vec3(0.4,0.4,0.4),vec3(0.3,0.3,0.3),1.0,0.0014,0.000007);
        //lights[2] = PointLight(vec3(3.0,4.0,3.0),vec3(0.1,0.1,0.1),vec3(0.8,0.8,0.8),vec3(0.6,0.6,0.6),1.0,0.0014,0.000007);

        DirLight dirlight = DirLight(vec3(cos(time),-1.0,sin(time)),vec3(0.4,0.4,0.4),vec3(1.0,1.0,1.0),vec3(0.2,0.2,0.2));

        if(true){
            for(int i = 0; i < NUM_LIGHTS; i++){
                vec3 p = camPos+t.x*d;
                vec3 nr = normal(p);
                vec3 light_dir = normalize(lights[i].position - p);
                float light_shadow = 0.0;
                if(!overRelaxation){
                    light_shadow = smoothstep(march(p+nr*0.001, light_dir).x,0.0,1.0);
                }
                else{
                    light_shadow = smoothstep(marchOverrelaxation(p+nr*0.001, light_dir, 0.001, 20.0, 0.01, true).x,0.0,1.0);
                }
                float diff = clamp(dot(nr,light_dir),0.0,1.0);

                vec3 viewDir = normalize(camPos - p);
                vec3 reflectDir = reflect(-light_dir, nr);
                float spec = 0.0;
                
                vec3 z = vec3(0.0);
                Material material;

                if(t.y == 1.0){
                    float f = smoothstep(0.2,0.1,sin(18.0*p.x)+sin(18.0*p.z)+sin(18.0*p.y));
                    material = bronze;
                    material.diffuse *= f;
                    material.shininess *= 100.0;
                }
                else if(t.y == 3.0){
                    material = gold;
                    material.shininess = 120.0;
                }
                else if(t.y == 2.0){
                    material = green_rubber;
                    material.shininess *= 10.0;
                }
                else if(t.y == 4.0){
                    float f = smoothstep(0.2,0.1,sin(18.0*p.x)+sin(18.0*p.z)+sin(18.0*p.y));
                    material = green_rubber;
                    material.diffuse *= f;
                    material.shininess *= 10.0;
                }
                
                vec3 ambient = lights[i].ambient * material.ambient;
                vec3 diffuse = lights[i].diffuse * (diff * material.diffuse) * softshadow(p,light_dir,0.01, 2.0, 32.0);
                
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
        else{
            vec3 p = camPos+t.x*d;
            vec3 nr = normal(p);
            vec3 viewDir = normalize(camPos - p);

            Material material;

            if(t.y == 1.0){
                float f = smoothstep(0.2,0.1,sin(18.0*p.x)+sin(18.0*p.z)+sin(18.0*p.y));
                material = bronze;
                material.diffuse *= f;
                material.shininess *= 100.0;
            }
            else if(t.y == 3.0){
                material = gold;
                material.shininess = 120.0;
            }
            else if(t.y == 2.0){
                material = green_rubber;
                material.shininess *= 10.0;
            }
            else if(t.y == 4.0){
                float f = smoothstep(0.2,0.1,sin(18.0*p.x)+sin(18.0*p.z)+sin(18.0*p.y));
                material = green_rubber;
                material.diffuse *= f;
                material.shininess *= 10.0;
            }

            vec3 lightDir = normalize(-dirlight.direction);
            // diffuse shading
            float diff = max(dot(nr, lightDir), 0.0);
            // specular shading
            vec3 reflectDir = reflect(-lightDir, nr);
            float spec = pow(max(dot(viewDir, reflectDir), 0.0), material.shininess);
            // combine results
            vec3 ambient  = dirlight.ambient  * material.ambient;
            vec3 diffuse  = dirlight.diffuse  * diff * material.diffuse * softshadow(p,lightDir,0.01, 2.0, 32.0);
            vec3 specular = dirlight.specular * spec * material.specular;
            
            col += ambient + diffuse + specular;
        }
    }

    vec3 skyCol = fogColor - d.y;
    col = mix(col, skyCol, fogAmount*smoothstep(0.,20.0,t.x));

    outColor = vec4(col,1.0);
}