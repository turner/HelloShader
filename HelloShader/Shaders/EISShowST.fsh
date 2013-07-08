//
//  EISShowST.fsh
//
precision highp float;

varying			vec2 v_st;
void main() {
	
	// Visualize the st parameterization of the underlying surface
	gl_FragColor.r = v_st.s;
	gl_FragColor.g = v_st.t;
	gl_FragColor.b = 0.0;
	gl_FragColor.a = 1.0;
	
}
