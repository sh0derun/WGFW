#ifdef GL_ES
precision mediump float;
#endif

uniform float time;
uniform vec2 resolution;

void main(void){
	vec2 p = gl_FragCoord.xy / resolution*2.0-1.0;
	p.x *= resolution.x / resolution.y;
	gl_FragColor = vec4(p*100.0,0.0,1.0);
}