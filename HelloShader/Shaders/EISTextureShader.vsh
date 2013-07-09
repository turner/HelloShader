//
//  EISTextureShader.vsh
//  HelloiPadGLSL
//
//  Created by turner on 2/25/10.
//  Copyright Douglass Turner Consulting 2010. All rights reserved.
//

attribute mediump	vec2	vertexST;
attribute highp		vec4	vertexXYZ;

// M - World space modeling matrix
uniform mediump mat4	modelMatrix;

// Surface normal transform is the inverse of M
uniform mediump mat4	normalMatrix;

// V * M - Eye space
uniform mediump mat4	viewModelMatrix;

// P * V * M - Projection space
uniform mediump mat4	projectionViewModelMatrix;

//
varying	mediump vec2 v_st;

void main() {

	gl_Position	= projectionViewModelMatrix * vertexXYZ;
		   v_st	= vertexST;
}
