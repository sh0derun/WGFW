#version 300 es

in vec2 a_position;
vec2 surfacePosition;
uniform vec2 screenRatio;

void main() {
   surfacePosition = a_position*screenRatio;
   gl_Position = vec4(a_position, 0, 1);
}