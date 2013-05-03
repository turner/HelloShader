//
//  ShowST.vsh
//  HelloiPadGLSL
//
//  Created by turner on 2/25/10.
//  Copyright Douglass Turner Consulting 2010. All rights reserved.
//

attribute highp vec4	myVertexXYZ;
attribute highp vec2	myVertexST;
attribute		vec4	myVertexRGBA;

// M - World space
uniform mediump mat4	myModelMatrix;

// The surface normal transform is the inverse of M
uniform mediump mat4	mySurfaceNormalMatrix;

// V * M - Eye space
uniform mediump mat4	myViewModelMatrix;

// P * V * M - Projection space
uniform mediump mat4	myProjectionViewModelMatrix;

//varying lowp	vec4 v_rgba;
varying			vec2 v_st;
void main() {

	gl_Position = myProjectionViewModelMatrix * myVertexXYZ;
	
	vec4 worldSpaceVertex = myModelMatrix * myVertexXYZ;
	
	// Ignore vertex colors
	vec4 dev_null = myVertexRGBA;

	v_st = myVertexST;

}
