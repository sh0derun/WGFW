struct Attenuation{
    float constant;
    float linear;
    float quadratic;
};

Attenuation attenuationLvl1 = Attenuation(1.0, 0.7, 1.8);
Attenuation attenuationLvl2 = Attenuation(1.0, 0.35, 0.44);
Attenuation attenuationLvl3 = Attenuation(1.0, 0.22, 0.20);
Attenuation attenuationLvl4 = Attenuation(1.0, 0.14, 0.07);
Attenuation attenuationLvl5 = Attenuation(1.0, 0.09, 0.032);
Attenuation attenuationLvl6 = Attenuation(1.0, 0.07, 0.017);
Attenuation attenuationLvl7 = Attenuation(1.0, 0.045, 0.0075);
Attenuation attenuationLvl8 = Attenuation(1.0, 0.027, 0.0028);
Attenuation attenuationLvl9 = Attenuation(1.0, 0.022, 0.0019);
Attenuation attenuationLvl10 = Attenuation(1.0, 0.014, 0.0007);
Attenuation attenuationLvl11 = Attenuation(1.0, 0.007, 0.0002);
Attenuation attenuationLvl12 = Attenuation(1.0, 0.0014, 0.000007);

struct PointLight {
    vec3 position;
    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
    Attenuation attenuation;
};

struct DirLight {
    vec3 direction;
    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
};

vec3 CalcDirLight(DirLight light, vec3 normal, vec3 viewDir, Material material){
    vec3 lightDir = normalize(-light.direction);
    // diffuse shading
    float diff = max(dot(normal, lightDir), 0.0);
    // specular shading
    vec3 reflectDir = reflect(-lightDir, normal);
    float spec = pow(max(dot(viewDir, reflectDir), 0.0), material.shininess);
    // combine results
    vec3 ambient  = light.ambient  * material.ambient;
    vec3 diffuse  = light.diffuse  * diff * material.diffuse;
    vec3 specular = light.specular * spec * material.specular;
    return (ambient + diffuse + specular);
}

vec3 fresnelSchlick(float cosTheta, vec3 F0){
    return F0 + (1.0 - F0) * pow(1.0 - cosTheta, 5.0);
}

float DistributionGGX(vec3 N, vec3 H, float roughness){
    float a      = roughness*roughness;
    float a2     = a*a;
    float NdotH  = max(dot(N, H), 0.0);
    float NdotH2 = NdotH*NdotH;
    
    float num   = a2;
    float denom = (NdotH2 * (a2 - 1.0) + 1.0);
    denom = PI * denom * denom;
    
    return num / max(denom,0.0000001);
}

float GeometrySchlickGGX(float NdotV, float roughness){
    float r = (roughness + 1.0);
    float k = (r*r) / 8.0;

    float num   = NdotV;
    float denom = NdotV * (1.0 - k) + k;
    
    return num / max(denom,0.0000001);
}

float GeometrySmith(vec3 N, vec3 V, vec3 L, float roughness){
    float NdotV = max(dot(N, V), 0.0);
    float NdotL = max(dot(N, L), 0.0);
    float ggx2  = GeometrySchlickGGX(NdotV, roughness);
    float ggx1  = GeometrySchlickGGX(NdotL, roughness);
    
    return ggx1 * ggx2;
}