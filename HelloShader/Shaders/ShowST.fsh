//
//  ShowST.fsh
//  HelloiPadGLSL
//
//  Created by turner on 2/25/10.
//  Copyright Douglass Turner Consulting 2010. All rights reserved.
//
precision highp float;

//varying lowp	vec4 v_rgba;
varying			vec2 v_st;
void main() {
	
	// Visualize the st parameterization of the underlying surface
	gl_FragColor.r = v_st.s;
	gl_FragColor.g = v_st.t;
	gl_FragColor.b = 0.0;
	gl_FragColor.a = 1.0;
	
}
