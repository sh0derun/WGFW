#version 300 es

in vec3 a_position;
vec2 surfacePosition;
uniform vec2 screenRatio;

void main() {
   //surfacePosition = a_position*vec3(screenRatio,1.0);
   gl_Position = vec4(a_position*vec3(screenRatio,1.0), 1);
}