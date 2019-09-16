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

	p.x += time*2.0;
	p.y += cos(time*3.0)*0.7;

	float r = 0.1;

	float s = smoothstep(r+0.01,r,length(p));

	vec3 col = vec3(1.0,0.6,0.35);

	col *= s;

	gl_FragColor = vec4(col,1.0);
}