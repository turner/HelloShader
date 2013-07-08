//
//  EISTextureShader.fsh
//
precision highp float;

varying	mediump vec2 v_st;

uniform sampler2D hero;

void main() {
	
	gl_FragColor = texture2D(hero, v_st);
	
}
