#version 300 es

precision highp float;

in vec3 vert_position;
in vec2 vert_texCoord;

out vec2 geom_texCoord;

void main() {
    gl_Position = vec4(vert_position, 1.0);
    geom_texCoord = vert_texCoord;
}