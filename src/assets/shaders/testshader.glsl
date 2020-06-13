#version 300 es

precision highp float;

#include<uniforms.glsl>

out vec4 outColor;

#include<constants.glsl>
#include<material.glsl>
#include<light.glsl>

vec3 drddx, drddy; 

#include<testshader_prologue.glsl>

int maxiter = 100;
int reflectionCount = 1;
float reflectionIntensity = 0.4;

vec3 blurSceene(vec2 fragCoord, vec2 resol, int blurKernelSize);
vec3 sceneShading(vec2 uv, vec3 o, vec3 d, SdfPhongResult t, vec3 kc);

vec3 O, Ot, D, Dt, P, N, kc = E.zzz; 

void main( void ){
    //outColor = vec4(sphere,1.0);return;
    vec2 uv = (gl_FragCoord.xy / resolution*2.0-1.0);
    uv.x *= resolution.x/resolution.y;

    float tm = time;
    O = vec3(camera.x*cos(tm),camera.y,camera.z*sin(tm))+1.5*sin(tm)*vec3(2.0*noise(tm*1.4),0.0,2.0*noise(tm*1.4));
    Ot = vec3(camera.x*cos(tm),camera.y,camera.z*sin(tm));//+1.5*sin(tm)*vec3(2.0*noise(tm*1.4),0.0,2.0*noise(tm*1.4));
    vec3 camTar = vec3(0.0,0.0,0.0);
    vec3 camDir = normalize(camTar - O);
    vec3 Up = vec3(0.0,1.0,0.0);
    vec3 camRight = normalize(cross(camDir,Up));
    vec3 camUp = cross(camRight, camDir);
            
    D = normalize(uv.x*camRight + uv.y*camUp + 1.5*camDir);
    Dt = normalize(uv.x*camRight + uv.y*camUp + 1.5*camDir);

    SdfPhongResult t = march(O, D, uv, maxiter);
    vec3 col = vec3(0.0);

    /*else{
        t.xy = marchOverrelaxation(O, D, 0.001, 20.0, 0.001, true);
    }*/

    if(t.d < MAX_DIST){
        if(t.m.reflective){
            for(int i = 0; i < 2; i++){
                SdfPhongResult t = march(O, D, uv, maxiter);
                P = O + D * t.d;
                N = normal(P);
                col += sceneShading(uv, O, D, t, kc);
                D = reflect(D, N);
                //O = P + D * t.x;
                O = P + D * 0.01;
                //D = refract(D, N, 1.0/1.333);
                kc *= 0.3*t.m.reflectance;
            }
        }
        else{
            col = sceneShading(uv, O, D, t, kc);
        }
    }

    //vec3 skyCol = fogColor - D.y;
    //col = mix(col, skyCol, fogAmount*smoothstep(0.,20.0,t.d));
   
    vec3 outputColor = col;

    //vec3 toneMappedColor = col/(col+1.0);
    //outputColor = pow(toneMappedColor, vec3(gamma));

    outColor = vec4(outputColor, 1.0);
}

vec3 sceneShading(vec2 uv, vec3 o, vec3 d, SdfPhongResult t, vec3 kc){
    vec3 col = vec3(0.0);

    vec3 ro = o, rd = d;
    vec3 p = ro+t.d*rd;
    vec3 nr = normal(p);
    float ao = uao.enabled ? calcAO(p, nr) : 1.0;

    vec3 lipos = vec3(2.0,3.0,2.0);
    PointLight lights[NUM_LIGHTS];
    lights[0] = PointLight(vec3(9.0,9.0,-2.0),vec3(1.0),vec3(1.0),vec3(0.2,0.2,0.2),attenuationLvl12);
    lights[1] = PointLight(vec3(-9.0,9.0,-2.0),vec3(1.0),vec3(1.0),vec3(0.3,0.3,0.3),attenuationLvl7);
    lights[2] = PointLight(vec3(-9.0,-9.0,-2.0),vec3(1.0),vec3(1.0),vec3(0.6,0.6,0.6),attenuationLvl7);
    lights[3] = PointLight(vec3(9.0,-9.0,-2.0),vec3(1.0),vec3(1.0),vec3(0.6,0.6,0.6),attenuationLvl7);
    /*lights[4] = PointLight(vec3(-7.0,0.0,-7.0),vec3(1.0,0.0,0.0),vec3(0.2),vec3(0.2,0.2,0.2),attenuationLvl7);
    lights[5] = PointLight(vec3(-7.0,0.0,7.0),vec3(0.0,1.0,0.0),vec3(0.5),vec3(0.3,0.3,0.3),attenuationLvl7);
    lights[6] = PointLight(vec3(7.0,0.0,-7.0),vec3(0.0,0.0,1.0),vec3(0.1),vec3(0.6,0.6,0.6),attenuationLvl7);
    lights[7] = PointLight(vec3(7.0,0.0,7.0),vec3(0.0,0.0,1.0),vec3(0.7),vec3(0.6,0.6,0.6),attenuationLvl7);*/

    DirLight dirlight = DirLight(vec3(cos(time),-4.0,sin(time)),vec3(0.4,0.4,0.4),vec3(0.5),vec3(0.2,0.2,0.2));

    if(true){
            for(int i = 0; i < NUM_LIGHTS; i++){
                vec3 light_dir = normalize(lights[i].position - p);
                /*float light_shadow = 0.0;
                if(!overRelaxation){
                    light_shadow = smoothstep(march(p+nr*0.001, light_dir, maxiter).x,0.0,1.0);
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
                    vec3 ambient = lights[i].ambient * t.m.ambient;// * smoothstep(vec3(-1.0),vec3(1.0),triplanarMap(p, nr, noisetex, 0.16));
                    vec3 diffuse = lights[i].diffuse * (diff * t.m.diffuse);// * smoothstep(vec3(-1.0),vec3(1.0),triplanarMap(p, nr, noisetex, 0.16));// * softshadow(p,light_dir,0.01, 3.0, 32.0);
                    
                    diffuse = gammacorrect(diffuse, gamma);

                    if(true){
                        vec3 halfwayDir = normalize(light_dir + viewDir);
                        spec = pow(max(dot(nr, halfwayDir), 0.0), t.m.shininess);
                    }
                    else{
                        vec3 reflectDir = reflect(-light_dir, nr);
                        spec = pow(clamp(dot(viewDir, reflectDir),0.0,1.0), t.m.shininess);
                    }
                    
                    vec3 specular = lights[i].specular * (spec * t.m.specular);
                    
                    float dist = length(lights[i].position - vec3(uv,0.0));
                    float attenuation = 1.0 / (lights[i].attenuation.constant + lights[i].attenuation.linear * dist + lights[i].attenuation.quadratic * (dist * dist));
                    
                    ambient *= attenuation;
                    diffuse *= attenuation;
                    specular *= attenuation;

                    col += t.m.emissive+kc*(ambient + diffuse + specular);
                }
                /*else if(pbrShading){
                    if(t.y == 0.0){
                        pbrMaterial = simpleMatGray;
                        pbrMaterial.emissive = pow((sin(2.0*p.x+5.0)*0.5+0.5),16.0)*vec3(0.3);
                    }
                    else if(t.y == 1.0){
                        PBRMaterial simpleMatNoisy = mixPBRMterial(simpleMatRed, simpleMatWhite, smoothstep(-0.3,0.3,sin(18.0*p.x)+sin(18.0*p.z)+sin(18.0*p.y)));
                        pbrMaterial = simpleMatNoisy;
                    }
                    else if(t.y == 3.0){
                        pbrMaterial = simpleMatOrange;
                        pbrMaterial.metalic = clamp(sphere.x*pbrMaterial.metalic,0.1,1.0);
                        pbrMaterial.roughness = clamp(sphere.y*pbrMaterial.roughness,0.1,1.0);
                        //p.y += sin(p.x);
                        //vec2 coords = p.xy;
                        //coords.y = abs(coords.y);
                        //pbrMaterial.emissive = pow(p.y,8.0)*vec3(0.,0.15,0.02);
                    }
                    else if(t.y == 2.0){
                        pbrMaterial = simpleMatGreen;
                    }   
                    else if(t.y == 4.0 || t.y == 6.0){
                        pbrMaterial = simpleMatGreen;
                    }
                    else if(t.y == 5.0){
                        pbrMaterial = simpleMatRed;
                        //pbrMaterial.metalic = clamp(speed*pbrMaterial.metalic,0.1,1.0);
                        //pbrMaterial.roughness = clamp(speed*pbrMaterial.roughness,0.1,1.0);
                    }
                    else if(t.y == 7.0){
                        PBRMaterial simpleMatNoisy = mixPBRMterial(simpleMatOrange, simpleMatBlue, smoothstep(-0.3,0.3,sin(18.0*p.x)+sin(18.0*p.z)+sin(18.0*p.y)));
                        pbrMaterial = simpleMatNoisy;
                    }

                    //material.albedo = saturate(material.albedo);
                    //material.metalic = saturate(material.metalic);
                    //material.roughness = saturate(material.roughness);

                    vec3 F0 = vec3(0.02);
                    F0 = mix(F0, pbrMaterial.albedo, pbrMaterial.metalic);

                    // calculate per-light radiance
                    vec3 L = light_dir;//normalize(lightPositions[i] - WorldPos);
                    vec3 H = normalize(viewDir + L);
                    float distance    = length(lights[i].position - p);
                    float attenuation = 1.0 / (distance * distance);
                    vec3 radiance     = lights[i].diffuse * attenuation;//* softshadow(p,light_dir,0.5, 3.0, 20.0*speed);        
                    
                    // cook-torrance brdf
                    float NDF = DistributionGGX(nr, H, pbrMaterial.roughness);
                    float G   = GeometrySmith(nr, viewDir, L, pbrMaterial.roughness);
                    vec3 F    = fresnelSchlick(max(dot(H, viewDir), 0.0), F0);
                    
                    vec3 kS = F;
                    vec3 kD = vec3(1.0) - kS;
                    kD *= 1.0 - pbrMaterial.metalic;
                    
                    vec3 numerator    = NDF * G * F;
                    float denominator = 4.0 * max(dot(nr, viewDir), 0.0) * max(dot(nr, L), 0.0);
                    vec3 specular     = numerator / max(denominator, 0.0000001);

                    // add to outgoing radiance Lo
                    float NdotL = max(dot(nr, L), 0.0);                
                    vec3 lightContribution = (kD * pbrMaterial.albedo / PI + specular) * radiance * NdotL;
                    
                    col += kc * (lightContribution + pbrMaterial.emissive);//ambient + diffuse + specular;
                }*/
            }
            /*if(pbrShading){
                vec3 amb = vec3(0.003) * pbrMaterial.albedo * ao;
                col += amb;
            }
            else if(phongShading){
                col += ao * speed;
            }*/
    }
    /*else{
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
            material.shininess *= 32.0;
        }
        else if(t.y == 4.0){
            float f = smoothstep(0.2,0.1,sin(18.0*p.x)+sin(18.0*p.z)+sin(18.0*p.y));
            material = green_rubber;
            material.diffuse *= f;
            material.shininess *= 64.0;
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
    }*/
    col *= ao;
    //col = col/(col+1.0);
    //col = pow(col, vec3(1.0/gamma));
    //col = pow(col, vec3(gamma));
    return col;
}