//
//  EISGaussianBlurNorthSouth.vsh
//
attribute highp		vec4	vertexXYZ;
attribute mediump	vec2	vertexST;

// P * V * M - Projection space
uniform mediump mat4 projectionViewModelMatrix;

varying	mediump vec2 v_st;

void main() {

	gl_Position	= projectionViewModelMatrix * vertexXYZ;
		   v_st	= vertexST;
	
}
