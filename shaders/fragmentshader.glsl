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

	vec3 t = vec3(0.0);

	for(float i = 0.0; i < 0.05; i+=0.025){
		p.x += cos(time*2.0)*0.11;
		p.y += sin(time*2.0)*0.11;
		float r = 0.05;
		float s = smoothstep(r+0.01,r,length(p));
		vec3 col = vec3(1.0+i,0.6+i,0.35+i);
		t += s*col;
	}
	gl_FragColor = vec4(t,1.0);
}