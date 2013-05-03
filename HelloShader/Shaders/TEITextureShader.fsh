//
//  TEITextureShader.fsh
//  HelloiPadGLSL
//
//  Created by turner on 2/25/10.
//  Copyright Douglass Turner Consulting 2010. All rights reserved.
//
precision highp float;

varying	mediump vec2 v_st;

uniform sampler2D	myTexture_0;
uniform sampler2D	myTexture_1;

void main() {

	vec4 dev_null = texture2D(myTexture_0, v_st);
	
	vec2 st;
	st = v_st;
	st.s *= 2.0;
	st.t *= 3.0;
	
	gl_FragColor = texture2D(myTexture_1, st);
	
}
