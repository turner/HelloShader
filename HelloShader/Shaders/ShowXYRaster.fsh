//
//  ShowXYRaster.fsh
//  HelloiPadGLSL
//
//  Created by turner on 2/25/10.
//  Copyright Douglass Turner Consulting 2010. All rights reserved.
//
precision highp float;

varying lowp	vec4 v_rgba;
varying			vec2 v_st;
void main() {
	
	gl_FragColor = v_rgba;
	
//	float depth = (gl_FragCoord.z - gl_DepthRange.near) / gl_DepthRange.diff;
	gl_FragColor.b = 0.0;
	gl_FragColor.a = 1.0;	

	// gl_FragCoord is in view coordinates:
	// 0 <= gl_FragCoord.x < view.bounds.size.width
	// 0 <= gl_FragCoord.y < view.bounds.size.height
	
	// Visualize the x-y window coordinates
//	if (gl_FragCoord.x < 768.0 / 2.0) {
//		gl_FragColor.r = 1.0;
//		gl_FragColor.g = 0.0;
//	} else {
//		gl_FragColor.r = 0.0;
//		gl_FragColor.g = 1.0;
//	}
//	
//	if (gl_FragCoord.y < 1024.0 / 2.0) {
//		gl_FragColor.r	/= 2.0;
//		gl_FragColor.g	/= 2.0;
//	}

//	gl_FragColor.r = step( 768.0/2.0, gl_FragCoord.x);
//	gl_FragColor.g = step(1024.0/2.0, gl_FragCoord.y);
	
	float edge;
	
	edge = 768.0/2.0;
	gl_FragColor.r = smoothstep(edge - edge/25.0, edge + edge/25.0, gl_FragCoord.x);
	
	edge = 1024.0/2.0;
	gl_FragColor.g = smoothstep(edge - edge/100.0, edge + edge/100.0, gl_FragCoord.y);
	
}
