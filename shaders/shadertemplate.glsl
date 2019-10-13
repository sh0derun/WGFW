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

int maxiter = 150;
int reflectionCount = 1;
float reflectionIntensity = 0.4;

vec3 blurSceene(vec2 fragCoord, vec2 resol, int blurKernelSize);
vec3 sceneShading(vec2 uv, vec3 o, vec3 d, vec3 t, vec3 kc);
float rayMarchingReflections( vec3 origin, vec3 dir, float start, float end );

vec3 O, D, P, N, kc = E.zzz;

void main( void ){
    vec2 uv = (gl_FragCoord.xy / resolution*2.0-1.0);
    uv.x *= resolution.x/resolution.y;
            
    float tm = time;
    O = vec3(camera.x*cos(tm),camera.y,camera.z*sin(tm))+1.5*sin(tm)*vec3(2.0*noise(tm*1.4),0.0,2.0*noise(tm*1.4));
    vec3 camTar = vec3(0.0,0.0,0.0);
    vec3 camDir = normalize(camTar - O);
    vec3 Up = vec3(0.0,1.0,0.0);
    vec3 camRight = normalize(cross(camDir,Up));
    vec3 camUp = cross(camRight, camDir);
            
    D = normalize(uv.x*camRight + uv.y*camUp + 1.5*camDir);

    vec3 t = vec3(0.0);
    vec3 col = vec3(0.0);
    
    if(!overRelaxation){
        t = march(O, D, maxiter);
    }
    else{
        t.xy = marchOverrelaxation(O, D, 0.001, 20.0, 0.001, true);
    }

    if(t.x < 20.0){
        if(t.y == 3.0){
            for(int i = 0; i < 2; i++){
                vec3 t = march(O, D, 100);
                P = O + D * t.x;
                N = normal(P);
                col += sceneShading(uv, O, D, t, kc);
                D = reflect(D, N);
                O = P + D * 0.01;
                kc *= 0.1*speed;
            }
        }
        else{
            col = sceneShading(uv, O, D, t, kc);
        }
    }

    vec3 skyCol = fogColor - D.y;
    col = mix(col, skyCol, fogAmount*smoothstep(0.,20.0,t.x));
   
    vec3 outputColor = col;

    vec3 toneMappedColor = col/(col+1.0);
    outputColor = pow(toneMappedColor, vec3(1.0/gamma));
    
    outColor = vec4(outputColor,1.0);
}

vec3 blurSceene(vec2 fragCoord, vec2 resol, int blurKernelSize){
    vec3 sum = vec3(0.0);

    for(int y = 0; y < blurKernelSize; y++){
        for(int x = 0; x < blurKernelSize; x++){
            vec2 offset = vec2(ivec2(x,y)-ivec2(blurKernelSize/2))/resol.xy;
            vec2 uv = (fragCoord / resol*2.0-1.0);
            uv.x *= resol.x/resol.y;
            uv += offset;
            
            float tm = time;
            vec3 camPos = vec3(camera.x,camera.y,camera.z)+1.0*vec3(2.0*noise(tm*0.5),noise(tm*0.4),2.0*noise(tm*1.4));
            vec3 camTar = vec3(0.0,0.0,0.0);
            vec3 camDir = normalize(camTar - camPos);
            vec3 Up = vec3(0.0,1.0,0.0);
            vec3 camRight = normalize(cross(camDir,Up));
            vec3 camUp = cross(camRight, camDir);
            
            vec3 d = normalize(uv.x*camRight + uv.y*camUp + 1.5*camDir);
            vec3 t = vec3(0.0);
            if(!overRelaxation){
                t = march(camPos,d, maxiter);
            }
            else{
                t.xy = marchOverrelaxation(camPos, d, 0.001, 20.0, 0.001, true);
            }

            vec3 col = vec3(0.0);

            if(t.x < 20.0){
                vec3 lipos = vec3(2.0,3.0,2.0);
                PointLight lights[NUM_LIGHTS];
                lights[0] = PointLight(vec3(-7.0,4.0,-7.0),vec3(1.0,0.0,0.0),vec3(1.0,0.1,0.2),vec3(0.2,0.2,0.2),attenuationLvl12);
                lights[1] = PointLight(vec3(-7.0,4.0,7.0),vec3(0.0,1.0,0.0),vec3(0.2,0.5,0.9),vec3(0.3,0.3,0.3),attenuationLvl12);
                lights[2] = PointLight(vec3(7.0,4.0,-7.0),vec3(0.0,0.0,1.0),vec3(0.9,0.2,0.1),vec3(0.6,0.6,0.6),attenuationLvl12);
                lights[3] = PointLight(vec3(7.0,4.0,7.0),vec3(0.0,0.0,1.0),vec3(0.9,0.9,0.1),vec3(0.6,0.6,0.6),attenuationLvl12);
                /*lights[4] = PointLight(vec3(-7.0,0.0,-7.0),vec3(1.0,0.0,0.0),vec3(1.0,0.1,0.2),vec3(0.2,0.2,0.2),attenuationLvl12);
                lights[5] = PointLight(vec3(-7.0,0.0,7.0),vec3(0.0,1.0,0.0),vec3(0.2,0.5,0.9),vec3(0.3,0.3,0.3),attenuationLvl12);
                lights[6] = PointLight(vec3(7.0,0.0,-7.0),vec3(0.0,0.0,1.0),vec3(0.9,0.2,0.1),vec3(0.6,0.6,0.6),attenuationLvl12);
                lights[7] = PointLight(vec3(7.0,0.0,7.0),vec3(0.0,0.0,1.0),vec3(0.9,0.9,0.1),vec3(0.6,0.6,0.6),attenuationLvl12);*/

                DirLight dirlight = DirLight(vec3(cos(time),-.5,sin(time)),vec3(0.4,0.4,0.4),vec3(1.0,1.0,1.0),vec3(0.2,0.2,0.2));

                if(true){            
                            for(int i = 0; i < NUM_LIGHTS; i++){
                                vec3 p = camPos+t.x*d;
                                vec3 nr = normal(p);
                                vec3 light_dir = normalize(lights[i].position - p);
                                float light_shadow = 0.0;
                                if(!overRelaxation){
                                    light_shadow = smoothstep(march(p+nr*0.001, light_dir, maxiter).x,0.0,1.0);
                                }
                                else{
                                    light_shadow = smoothstep(marchOverrelaxation(p+nr*0.001, light_dir, 0.001, 20.0, 0.01, true).x,0.0,1.0);
                                }
                                //float diff = clamp(dot(nr,light_dir),0.0,1.0);

                                vec3 viewDir = normalize(camPos - p);
                                vec3 reflectDir = reflect(-light_dir, nr);
                                //float spec = 0.0;
                                
                                vec3 z = vec3(0.0);

                                /*if(t.y == 1.0){
                                    float f = smoothstep(-0.3,0.3,sin(18.0*p.x)+sin(18.0*p.z)+sin(18.0*p.y));
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
                                    float f = smoothstep(-0.5,0.5,sin(18.0*p.x)+sin(18.0*p.z)+pow(sin(18.0*p.y),2.0));
                                    material = green_rubber;
                                    material.diffuse *= f;
                                    material.shininess *= 10.0;
                                }*/
                                
                                //vec3 ambient = lights[i].ambient * material.ambient;
                                //vec3 diffuse = lights[i].diffuse * (diff * material.diffuse); /* softshadow(p,light_dir,0.01, 3.0, 32.0);*/
                                
                                //diffuse = pow(diffuse, vec3(gamma));
                                /*
                                if(false){
                                    vec3 halfwayDir = normalize(light_dir + viewDir);
                                    spec = pow(max(dot(nr, halfwayDir), 0.0), material.shininess);
                                }
                                else{
                                    vec3 reflectDir = reflect(-light_dir, nr);
                                    spec = pow(max(dot(viewDir, reflectDir), 0.0), material.shininess);
                                }*/
                                
                                //vec3 specular = lights[i].specular * (spec * material.specular);
                                
                                //float dist = length(lights[i].position - vec3(uv,0.0));
                                //float attenuation = 1.0 / (lights[i].constant + lights[i].linear * dist + lights[i].quadratic * (dist * dist));
                                
                                //ambient *= attenuation;
                                //diffuse *= attenuation;
                                //specular *= attenuation;

                                PBRMaterial material;

                                if(t.y == 1.0){
                                    PBRMaterial simpleMatNoisy = mixPBRMterial(simpleMatRed, simpleMatWhite, smoothstep(-0.3,0.3,sin(18.0*p.x)+sin(18.0*p.z)+sin(18.0*p.y)));
                                    material = simpleMatNoisy;
                                }
                                else if(t.y == 3.0){
                                    material = simpleMatRed;
                                    //p.y += sin(p.x);
                                    vec2 coords = p.xy;
                                    coords.y = abs(coords.y);
                                    material.emissive = /*pow((sin(20.0*coords.y+time*10.0)*0.5+0.5),8.0)*/vec3(0.,0.15,0.02);
                                }
                                else if(t.y == 2.0){
                                    material = simpleMatGreen;
                                }   
                                else if(t.y == 4.0){
                                    material = simpleMatGreen;
                                }

                                vec3 F0 = vec3(0.56, 0.57, 0.58); 
                                F0 = mix(F0, material.albedo, material.metalic);

                                // calculate per-light radiance
                                vec3 L = light_dir;//normalize(lightPositions[i] - WorldPos);
                                vec3 H = normalize(viewDir + L);
                                float distance    = length(lights[i].position - p);
                                float attenuation = 1.0 / (distance * distance);
                                vec3 radiance     = lights[i].diffuse * attenuation;        
                                
                                // cook-torrance brdf
                                float NDF = DistributionGGX(nr, H, material.roughness);
                                float G   = GeometrySmith(nr, viewDir, L, material.roughness);
                                vec3 F    = fresnelSchlick(max(dot(H, viewDir), 0.0), F0);
                                
                                vec3 kS = F;
                                vec3 kD = vec3(1.0) - kS;
                                kD *= 1.0 - material.metalic;
                                
                                vec3 numerator    = NDF * G * F;
                                float denominator = 4.0 * max(dot(nr, viewDir), 0.0) * max(dot(nr, L), 0.0);
                                vec3 specular     = numerator / max(denominator, 0.001);

                                // add to outgoing radiance Lo
                                float NdotL = max(dot(nr, L), 0.0);                
                                vec3 lightContribution = (kD * material.albedo / PI + specular) * radiance * NdotL;
                                
                                col += lightContribution + material.emissive;//ambient + diffuse + specular;
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
            sum += col*(1.0/float(blurKernelSize*blurKernelSize));
        }
    }
    return sum;
}

vec3 sceneShading(vec2 uv, vec3 o, vec3 d, vec3 t, vec3 kc){
    vec3 col = vec3(0.0);

    vec3 ro = o, rd = d;

    vec3 lipos = vec3(2.0,3.0,2.0);
    PointLight lights[NUM_LIGHTS];
    lights[0] = PointLight(vec3(-7.0,4.0,-7.0),vec3(1.0,0.0,0.0),vec3(1.0,0.1,0.2),vec3(0.2,0.2,0.2),attenuationLvl12);
    lights[1] = PointLight(vec3(-7.0,4.0,7.0),vec3(0.0,1.0,0.0),vec3(0.2,0.5,0.9),vec3(0.3,0.3,0.3),attenuationLvl12);
    lights[2] = PointLight(vec3(7.0,4.0,-7.0),vec3(0.0,0.0,1.0),vec3(0.9,0.2,0.1),vec3(0.6,0.6,0.6),attenuationLvl12);
    lights[3] = PointLight(vec3(7.0,4.0,7.0),vec3(0.0,0.0,1.0),vec3(0.9,0.9,0.1),vec3(0.6,0.6,0.6),attenuationLvl12);
    /*lights[4] = PointLight(vec3(-7.0,0.0,-7.0),vec3(1.0,0.0,0.0),vec3(1.0,0.1,0.2),vec3(0.2,0.2,0.2),attenuationLvl12);
    lights[5] = PointLight(vec3(-7.0,0.0,7.0),vec3(0.0,1.0,0.0),vec3(0.2,0.5,0.9),vec3(0.3,0.3,0.3),attenuationLvl12);
    lights[6] = PointLight(vec3(7.0,0.0,-7.0),vec3(0.0,0.0,1.0),vec3(0.9,0.2,0.1),vec3(0.6,0.6,0.6),attenuationLvl12);
    lights[7] = PointLight(vec3(7.0,0.0,7.0),vec3(0.0,0.0,1.0),vec3(0.9,0.9,0.1),vec3(0.6,0.6,0.6),attenuationLvl12);*/

    DirLight dirlight = DirLight(vec3(cos(time),-.5,sin(time)),vec3(0.4,0.4,0.4),vec3(1.0,1.0,1.0),vec3(0.2,0.2,0.2));

    if(true){
            for(int i = 0; i < NUM_LIGHTS; i++){
                vec3 p = ro+t.x*rd;
                vec3 nr = normal(p);
                vec3 light_dir = normalize(lights[i].position - p);
                /*float light_shadow = 0.0;
                if(!overRelaxation){
                    light_shadow = smoothstep(march(p+nr*0.001, light_dir).x,0.0,1.0);
                }
                else{
                    light_shadow = smoothstep(marchOverrelaxation(p+nr*0.001, light_dir, 0.001, 20.0, 0.01, true).x,0.0,1.0);
                }*/
                float diff = clamp(dot(nr,light_dir),0.0,1.0);

                vec3 viewDir = normalize(ro - p);
                vec3 reflectDir = reflect(-light_dir, nr);

                float spec = 0.0;
                                    
                vec3 z = vec3(0.0);
                                
                if(phongShading){
                    Material material;
                    if(t.y == 0.0){
                        material = yellow_rubber;
                        material.shininess *= 10.0;
                        material.emissive = vec3(0.3)*speed;
                    }
                    else if(t.y == 1.0){
                        float f = smoothstep(-0.3,0.3,sin(18.0*p.x)+sin(18.0*p.z)+sin(18.0*p.y));
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
                        float f = smoothstep(-0.5,0.5,sin(18.0*p.x)+sin(18.0*p.z)+pow(sin(18.0*p.y),2.0));
                        material = green_rubber;
                        material.diffuse *= f;
                        material.shininess *= 10.0;
                    }
                    else if(t.y == 5.0){
                        material = turquoise;
                        material.shininess *= 100.0;
                    }

                    vec3 ambient = lights[i].ambient * material.ambient;
                    vec3 diffuse = lights[i].diffuse * (diff * material.diffuse);// * softshadow(p,light_dir,0.01, 3.0, 32.0);
                            
                    diffuse = pow(diffuse, vec3(gamma));
                            
                    if(false){
                        vec3 halfwayDir = normalize(light_dir + viewDir);
                        spec = pow(max(dot(nr, halfwayDir), 0.0), material.shininess);
                    }
                    else{
                        vec3 reflectDir = reflect(-light_dir, nr);
                        spec = pow(max(dot(viewDir, reflectDir), 0.0), material.shininess);
                    }
                    
                    vec3 specular = lights[i].specular * (spec * material.specular);
                    
                    float dist = length(lights[i].position - vec3(uv,0.0));
                    float attenuation = 1.0 / (lights[i].attenuation.constant + lights[i].attenuation.linear * dist + lights[i].attenuation.quadratic * (dist * dist));
                    
                    ambient *= attenuation;
                    diffuse *= attenuation;
                    specular *= attenuation;

                    col += material.emissive+kc*(ambient + diffuse + specular);
                }
                else if(pbrShading){
                    PBRMaterial material;
                    if(t.y == 0.0){
                        material = simpleMatGray;
                        material.emissive = pow((speed*sin(10.0*p.x)*0.5+0.5),30.0)*vec3(0.3);
                    }
                    else if(t.y == 1.0){
                        PBRMaterial simpleMatNoisy = mixPBRMterial(simpleMatRed, simpleMatWhite, smoothstep(-0.3,0.3,sin(18.0*p.x)+sin(18.0*p.z)+sin(18.0*p.y)));
                        material = simpleMatNoisy;
                    }
                    else if(t.y == 3.0){
                        material = simpleMatOrange;
                        //material.metalic = clamp(speed*material.metalic,0.1,1.0);
                        //material.roughness = clamp(speed*material.roughness,0.1,1.0);
                        //p.y += sin(p.x);
                        //vec2 coords = p.xy;
                        //coords.y = abs(coords.y);
                        //material.emissive = pow((sin(20.0*p.y+time*10.0)*0.5+0.5),8.0)*vec3(0.,0.15,0.02);
                    }
                    else if(t.y == 2.0){
                        material = simpleMatGreen;
                    }   
                    else if(t.y == 4.0){
                        material = simpleMatGreen;
                    }
                    else if(t.y == 5.0){
                        material = simpleMatRed;
                        //material.metalic = clamp(speed*material.metalic,0.1,1.0);
                        //material.roughness = clamp(speed*material.roughness,0.1,1.0);
                    }

                    vec3 F0 = vec3(0.02, 0.02, 0.02);
                    F0 = mix(F0, material.albedo, material.metalic);

                    // calculate per-light radiance
                    vec3 L = light_dir;//normalize(lightPositions[i] - WorldPos);
                    vec3 H = normalize(viewDir + L);
                    float distance    = length(lights[i].position - p);
                    float attenuation = 1.0 / (distance * distance);
                    vec3 radiance     = lights[i].diffuse * attenuation;        
                    
                    // cook-torrance brdf
                    float NDF = DistributionGGX(nr, H, material.roughness);
                    float G   = GeometrySmith(nr, viewDir, L, material.roughness);
                    vec3 F    = fresnelSchlick(max(dot(H, viewDir), 0.0), F0);
                    
                    vec3 kS = F;
                    vec3 kD = vec3(1.0) - kS;
                    kD *= 1.0 - material.metalic;
                    //kD *= softshadow(p,light_dir,0.01, 3.0, 32.0);
                    
                    vec3 numerator    = NDF * G * F;
                    float denominator = 4.0 * max(dot(nr, viewDir), 0.0) * max(dot(nr, L), 0.0);
                    vec3 specular     = numerator / max(denominator, 0.001);

                    // add to outgoing radiance Lo
                    float NdotL = max(dot(nr, L), 0.0);                
                    vec3 lightContribution = (kD * material.albedo / PI + specular) * radiance * NdotL;
                    
                    col += kc * lightContribution + material.emissive;//ambient + diffuse + specular;
                }
            }
    }
    else{
        vec3 p = ro+t.x*rd;
        vec3 nr = normal(p);
        vec3 viewDir = normalize(ro - p);

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

    return col;
}