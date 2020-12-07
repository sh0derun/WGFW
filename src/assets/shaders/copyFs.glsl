#version 300 es

precision highp float;

in vec2 geom_texCoord;

uniform highp sampler2D textures;
uniform bool bloom;

out vec4 outColor;

#define saturate(x) (clamp((x),0.0,1.0))

void main() {
    vec3 clean = texture(textures, geom_texCoord).xyz;
    vec3 acc = vec3(0.0);
    int kernelSize = 15;
    if(bloom){
        for(int y = 0; y < kernelSize; y++){
            for(int x = 0; x < kernelSize; x++){
                vec2 offset = vec2(ivec2(x,y)-ivec2(kernelSize/2))/vec2(200.0);
                acc += texture(textures, geom_texCoord + offset).xyz * (1.0 / float(kernelSize*kernelSize));
            }
        }
    }
    //acc = saturate(pow(acc + 0.03, vec3(4.4)));
    outColor = vec4(clean + acc, 1.0);
}