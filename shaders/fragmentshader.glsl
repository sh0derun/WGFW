#ifdef GL_ES
precision mediump float;
#endif

#extension GL_OES_standard_derivatives : enable

uniform float time;
uniform vec2 resolution;

mat2 rot(float a){float c = cos(a), s = sin(a); return mat2(c,-s,s,c);}

void main(void){
	vec2 p = gl_FragCoord.xy / resolution*2.0-1.0;
	p.x *= resolution.x / resolution.y;
	float a = time * 0.5;
	gl_FragColor = vec4(sin(time));
}