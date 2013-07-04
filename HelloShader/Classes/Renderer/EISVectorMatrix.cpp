/*
 *  EISVectorMatrix.cpp
 *
 *  Created by Douglass Turner on 12/1/10.
 *  Copyright 2010 Elastic Image Software LLC. All rights reserved.
 *
 */

#include <math.h>
#include <string.h>
#include <stdio.h>
#include "EISVectorMatrix.h"

static inline float EISAbs(float x) { 
	return (x < 0) ? -x : x; 
}

static inline float EISFastSin(float x) {
	
	// fast sin function; maximum error is 0.001
	const float P = 0.225f;
	
	x = x * M_1_PI;
	int k = (int) roundf(x);
	x = x - k;
    
	float y = (4.0f - 4.0f * EISAbs(x)) * x;
    
	y = P * (y * EISAbs(y) - y) + y;
    
	return (k&1) ? -y : y;
}

static inline float EISFastCos(float x) {
	
	return EISFastSin(x + M_PI_2);
	
}


static EISMatrix4x4	_eis_vector_matrix_identity_matrix_4x4_ = 
{ 
	1.0f, 0.0f, 0.0f, 0.0f,
	0.0f, 1.0f, 0.0f, 0.0f,
	0.0f, 0.0f, 1.0f, 0.0f,
	0.0f, 0.0f, 0.0f, 1.0f 
};

#pragma mark -
#pragma mark Vector3D Functions
#pragma mark -

void EISVector3DSet(EISVector3D v, float x, float y, float z) { 
	v[0] = x; 
	v[1] = y; 
	v[2] = z; 
}

void EISVector3DCopy(EISVector3D dst, EISVector3D src) { 
	memcpy(dst, src, sizeof(EISVector3D)); 
}

void EISVector3DAdd(EISVector3D r, EISVector3D a, EISVector3D b) { 
	r[0] = a[0] + b[0];	
	r[1] = a[1] + b[1]; 
	r[2] = a[2] + b[2]; 
}

void EISVector3DSubtract(EISVector3D r, EISVector3D a, EISVector3D b) { 
	r[0] = a[0] - b[0]; 
	r[1] = a[1] - b[1]; 
	r[2] = a[2] - b[2];
}

void EISVector3DScale(EISVector3D v, float scale) { 
	v[0] *= scale; 
	v[1] *= scale; 
	v[2] *= scale; 
}

void EISVector3DCrossProduct(EISVector3D result, EISVector3D u, EISVector3D v) {
	result[0] =  u[1]*v[2] - v[1]*u[2];
	result[1] = -u[0]*v[2] + v[0]*u[2];
	result[2] =  u[0]*v[1] - v[0]*u[1];
}

float EISVector3DDotProduct(EISVector3D u, EISVector3D v) { 
	return u[0]*v[0] + u[1]*v[1] + u[2]*v[2]; 
}

float EISVector3DAngleBetween(EISVector3D u, EISVector3D v) {
	
    float dot = EISVector3DDotProduct(u, v);
    return acosf(dot);
}

float EISVector3DLength(EISVector3D u) { 
	return sqrtf(m3dGetVectorLengthSquaredf(u)); 
}

float m3dGetVectorLengthSquaredf(EISVector3D u) { 
	return (u[0] * u[0]) + (u[1] * u[1]) + (u[2] * u[2]); 
}

void EISVector3DNormalize(EISVector3D u) { 
	EISVector3DScale(u, 1.0f / EISVector3DLength(u)); 
}

#pragma mark -
#pragma mark Matrix 4x4 Functions
#pragma mark -

void EISMatrix4x4Multiply(EISMatrix4x4 B, EISMatrix4x4 A, EISMatrix4x4 concatenation) {
	
    concatenation[ 0] = B[0] * A[ 0] + B[4] * A[ 1] + B[ 8] * A [2] + B[12] * A[ 3];
    concatenation[ 1] = B[1] * A[ 0] + B[5] * A[ 1] + B[ 9] * A[ 2] + B[13] * A[ 3];
    concatenation[ 2] = B[2] * A[ 0] + B[6] * A[ 1] + B[10] * A[ 2] + B[14] * A[ 3];
    concatenation[ 3] = B[3] * A[ 0] + B[7] * A[ 1] + B[11] * A[ 2] + B[15] * A[ 3];
    
    concatenation[ 4] = B[0] * A[ 4] + B[4] * A[ 5] + B[ 8] * A[ 6] + B[12] * A[ 7];
    concatenation[ 5] = B[1] * A[ 4] + B[5] * A[ 5] + B[ 9] * A[ 6] + B[13] * A[ 7];
    concatenation[ 6] = B[2] * A[ 4] + B[6] * A[ 5] + B[10] * A[ 6] + B[14] * A[ 7];
    concatenation[ 7] = B[3] * A[ 4] + B[7] * A[ 5] + B[11] * A[ 6] + B[15] * A[ 7];
    
    concatenation[ 8] = B[0] * A[ 8] + B[4] * A[ 9] + B[ 8] * A[10] + B[12] * A[11];
    concatenation[ 9] = B[1] * A[ 8] + B[5] * A [9] + B[ 9] * A[10] + B[13] * A[11];
    concatenation[10] = B[2] * A[ 8] + B[6] * A[ 9] + B[10] * A[10] + B[14] * A[11];
    concatenation[11] = B[3] * A[ 8] + B[7] * A[ 9] + B[11] * A[10] + B[15] * A[11];
    
    concatenation[12] = B[0] * A[12] + B[4] * A[13] + B[ 8] * A[14] + B[12] * A[15];
    concatenation[13] = B[1] * A[12] + B[5] * A[13] + B[ 9] * A[14] + B[13] * A[15];
    concatenation[14] = B[2] * A[12] + B[6] * A[13] + B[10] * A[14] + B[14] * A[15];
    concatenation[15] = B[3] * A[12] + B[7] * A[13] + B[11] * A[14] + B[15] * A[15];
	
}

void EISConcatenate(EISMatrix4x4 B, EISMatrix4x4 A) {
	
    A[ 0] = B[0] * A[ 0] + B[4] * A[ 1] + B[ 8] * A [2] + B[12] * A[ 3];
    A[ 1] = B[1] * A[ 0] + B[5] * A[ 1] + B[ 9] * A[ 2] + B[13] * A[ 3];
    A[ 2] = B[2] * A[ 0] + B[6] * A[ 1] + B[10] * A[ 2] + B[14] * A[ 3];
    A[ 3] = B[3] * A[ 0] + B[7] * A[ 1] + B[11] * A[ 2] + B[15] * A[ 3];
    
    A[ 4] = B[0] * A[ 4] + B[4] * A[ 5] + B[ 8] * A[ 6] + B[12] * A[ 7];
    A[ 5] = B[1] * A[ 4] + B[5] * A[ 5] + B[ 9] * A[ 6] + B[13] * A[ 7];
    A[ 6] = B[2] * A[ 4] + B[6] * A[ 5] + B[10] * A[ 6] + B[14] * A[ 7];
    A[ 7] = B[3] * A[ 4] + B[7] * A[ 5] + B[11] * A[ 6] + B[15] * A[ 7];
    
    A[ 8] = B[0] * A[ 8] + B[4] * A[ 9] + B[ 8] * A[10] + B[12] * A[11];
    A[ 9] = B[1] * A[ 8] + B[5] * A [9] + B[ 9] * A[10] + B[13] * A[11];
    A[10] = B[2] * A[ 8] + B[6] * A[ 9] + B[10] * A[10] + B[14] * A[11];
    A[11] = B[3] * A[ 8] + B[7] * A[ 9] + B[11] * A[10] + B[15] * A[11];
    
    A[12] = B[0] * A[12] + B[4] * A[13] + B[ 8] * A[14] + B[12] * A[15];
    A[13] = B[1] * A[12] + B[5] * A[13] + B[ 9] * A[14] + B[13] * A[15];
    A[14] = B[2] * A[12] + B[6] * A[13] + B[10] * A[14] + B[14] * A[15];
    A[15] = B[3] * A[12] + B[7] * A[13] + B[11] * A[14] + B[15] * A[15];
		
}

void EISMatrix4x4SetIdentity(EISMatrix4x4 matrix) {
	
	memcpy(matrix, _eis_vector_matrix_identity_matrix_4x4_, sizeof(EISMatrix4x4));
}

void EISMatrix4x4Set(EISMatrix4x4 dst, EISMatrix4x4 src) {
	memcpy(dst, src, sizeof(EISMatrix4x4)); 
}

void EISMatrix4x4SetTranslation(EISMatrix4x4 matrix, float xTranslate, float yTranslate, float zTranslate) {
	
	EISMatrix4x4SetIdentity(matrix);
    matrix[12] = xTranslate; 
	matrix[13] = yTranslate; 
	matrix[14] = zTranslate;   
}

void EISMatrix4x4SetScaling(EISMatrix4x4 matrix, float xScale, float yScale, float zScale) {
	
	EISMatrix4x4SetIdentity(matrix);
    matrix[ 0] = xScale;
    matrix[ 5] = yScale;
    matrix[10] = zScale;
	
	//    matrix[15] = 1.0;
}

void EISMatrix4x4SetUniformScaling(EISMatrix4x4 matrix, float scale) {
	
    EISMatrix4x4SetScaling(matrix, scale, scale, scale);
}

void EISMatrix4x4SetXRotationUsingRadians(EISMatrix4x4 matrix, float rad) {
	
	EISMatrix4x4SetIdentity(matrix);
	
    float s		= sinf(rad); 
    float c		= cosf(rad);	
	
	// This is from my render system. Read the matrix as m[columns][rows]
	float xform[3][3];
	
    xform[0][0] = 1;	xform[0][1] =  0;	xform[0][2] = 0;
    xform[1][0] = 0;	xform[1][1] =  c;	xform[1][2] = s;
    xform[2][0] = 0;	xform[2][1] = -s;	xform[2][2] = c;
	
	// Stuff the matrix into my format
	MatrixElement(matrix, 0, 0) = xform[0][0];
	MatrixElement(matrix, 0, 1) = xform[1][0];
	MatrixElement(matrix, 0, 2) = xform[2][0];
	
	MatrixElement(matrix, 1, 0) = xform[0][1];
	MatrixElement(matrix, 1, 1) = xform[1][1];
	MatrixElement(matrix, 1, 2) = xform[2][1];
	
	MatrixElement(matrix, 2, 0) = xform[0][2];
	MatrixElement(matrix, 2, 1) = xform[1][2];
	MatrixElement(matrix, 2, 2) = xform[2][2];
	
}

void EISMatrix4x4SetXRotationUsingDegrees(EISMatrix4x4 matrix, float deg) {
	
    EISMatrix4x4SetXRotationUsingRadians(matrix, EISDegreeToRadian(deg));
}

void EISMatrix4x4SetYRotationUsingRadians(EISMatrix4x4 matrix, float rad) {
	
	EISMatrix4x4SetIdentity(matrix);
	
    float s		= sinf(rad); 
    float c		= cosf(rad);	
	
	// This is from my render system. Read the matrix as m[columns][rows]
	float xform[3][3];
	
    xform[0][0] = c;	xform[0][1] = 0;	xform[0][2] = -s;
    xform[1][0] = 0;	xform[1][1] = 1;	xform[1][2] =  0;
    xform[2][0] = s;	xform[2][1] = 0;	xform[2][2] =  c;
	
	// Stuff the matrix into my format
	MatrixElement(matrix, 0, 0) = xform[0][0];
	MatrixElement(matrix, 0, 1) = xform[1][0];
	MatrixElement(matrix, 0, 2) = xform[2][0];
	
	MatrixElement(matrix, 1, 0) = xform[0][1];
	MatrixElement(matrix, 1, 1) = xform[1][1];
	MatrixElement(matrix, 1, 2) = xform[2][1];
	
	MatrixElement(matrix, 2, 0) = xform[0][2];
	MatrixElement(matrix, 2, 1) = xform[1][2];
	MatrixElement(matrix, 2, 2) = xform[2][2];
	
}

void EISMatrix4x4SetYRotationUsingDegrees(EISMatrix4x4 matrix, float deg) {
	
    EISMatrix4x4SetYRotationUsingRadians(matrix, EISDegreeToRadian(deg));
}

void EISMatrix4x4SetZRotationUsingRadians(EISMatrix4x4 matrix, float rad) {
	
	EISMatrix4x4SetIdentity(matrix);
	
    float s		= sinf(rad); 
    float c		= cosf(rad);	
	
	// This is from my render system. Read the matrix as m[columns][rows]
	float xform[3][3];
	
    xform[0][0] =  c;	xform[0][1] = s;	xform[0][2] = 0;
    xform[1][0] = -s;	xform[1][1] = c;	xform[1][2] = 0;
    xform[2][0] =  0;	xform[2][1] = 0;	xform[2][2] = 1;
	
	// Stuff the matrix into my format
	MatrixElement(matrix, 0, 0) = xform[0][0];
	MatrixElement(matrix, 0, 1) = xform[1][0];
	MatrixElement(matrix, 0, 2) = xform[2][0];
	
	MatrixElement(matrix, 1, 0) = xform[0][1];
	MatrixElement(matrix, 1, 1) = xform[1][1];
	MatrixElement(matrix, 1, 2) = xform[2][1];
	
	MatrixElement(matrix, 2, 0) = xform[0][2];
	MatrixElement(matrix, 2, 1) = xform[1][2];
	MatrixElement(matrix, 2, 2) = xform[2][2];
	
}

void EISMatrix4x4SetZRotationUsingDegrees(EISMatrix4x4 matrix, float deg) {
	
    EISMatrix4x4SetZRotationUsingRadians(matrix, EISDegreeToRadian(deg));
}

void EISUIViewToWorldSpaceRay (CGPoint inScreenSpace, float *projViewModel, CGSize viewportSize, EISMatrix4x4 inWorldSpace) {
	
	int result = -1;
	
	float projViewModelInvert[16];
	result = EISMatrix4x4Inverse(projViewModel, projViewModelInvert);
	
	// Convert from screen space to NDC (-1 < xyz < +1)
	float inProjectionSpace[4];
	inProjectionSpace[0] = ((inScreenSpace.x / viewportSize.width ) * 2.0) - 1.0;
	inProjectionSpace[1] = ((inScreenSpace.y / viewportSize.height) * 2.0) - 1.0;
	
	// Right in the middle of the NDC cube
	inProjectionSpace[2] = 0.0;
	
	inProjectionSpace[3] = 1.0;
	
	
	float tmp[4];
	
	// row 1
	tmp[0] = 
	projViewModelInvert[_11] * inProjectionSpace[0] + 
	projViewModelInvert[_21] * inProjectionSpace[1] + 
	projViewModelInvert[_31] * inProjectionSpace[2] + 
	projViewModelInvert[_41] * inProjectionSpace[3];
	
	// row 2
	tmp[1] = 
	projViewModelInvert[_12] * inProjectionSpace[0] + 
	projViewModelInvert[_22] * inProjectionSpace[1] + 
	projViewModelInvert[_32] * inProjectionSpace[2] + 
	projViewModelInvert[_42] * inProjectionSpace[3];
	
	// row 3
	tmp[2] = 
	projViewModelInvert[_13] * inProjectionSpace[0] + 
	projViewModelInvert[_23] * inProjectionSpace[1] + 
	projViewModelInvert[_33] * inProjectionSpace[2] + 
	projViewModelInvert[_43] * inProjectionSpace[3];
	
	// row 4
	tmp[3] = 
	projViewModelInvert[_14] * inProjectionSpace[0] + 
	projViewModelInvert[_24] * inProjectionSpace[1] + 
	projViewModelInvert[_34] * inProjectionSpace[2] + 
	projViewModelInvert[_44] * inProjectionSpace[3];
	
	// divide by the homogenous coefficient "w"
	inWorldSpace[0] = tmp[0] / tmp[3];
	inWorldSpace[1] = tmp[1] / tmp[3];
	inWorldSpace[2] = tmp[2] / tmp[3]; 
	
}

#pragma mark -
#pragma mark Projective Matrix Inverse
#pragma mark -

int EISMatrix4x4Inverse(float *m, float *out) {

#define SWAP_ROWS_DOUBLE(a, b) { double *_tmp = a; (a)=(b); (b)=_tmp; }
#define SWAP_ROWS_FLOAT(a, b) { float *_tmp = a; (a)=(b); (b)=_tmp; }
#define MAT(m,r,c) (m)[(c)*4+(r)]
		
	float wtmp[4][8];
	float m0, m1, m2, m3, s;
//	float *r0, *r1, *r2, *r3;
	
	float *r0 = wtmp[0];
	r0[0] = MAT(m, 0, 0), 
	r0[1] = MAT(m, 0, 1),
	r0[2] = MAT(m, 0, 2), 
	r0[3] = MAT(m, 0, 3),
	r0[4] = 1.0, 
	r0[5] = r0[6] = r0[7] = 0.0;
	
	float *r1 = wtmp[1];
	r1[0] = MAT(m, 1, 0), 
	r1[1] = MAT(m, 1, 1),
	r1[2] = MAT(m, 1, 2), 
	r1[3] = MAT(m, 1, 3),
	r1[5] = 1.0, 
	r1[4] = r1[6] = r1[7] = 0.0;
	
	float *r2 = wtmp[2];
	r2[0] = MAT(m, 2, 0), 
	r2[1] = MAT(m, 2, 1),
	r2[2] = MAT(m, 2, 2), 
	r2[3] = MAT(m, 2, 3),
	r2[6] = 1.0, 
	r2[4] = r2[5] = r2[7] = 0.0;
	
	float *r3 = wtmp[3];
	r3[0] = MAT(m, 3, 0), 
	r3[1] = MAT(m, 3, 1),
	r3[2] = MAT(m, 3, 2), 
	r3[3] = MAT(m, 3, 3),
	r3[7] = 1.0, 
	r3[4] = r3[5] = r3[6] = 0.0;
	
	/* choose pivot - or die */
	if (fabsf(r3[0]) > fabsf(r2[0])) SWAP_ROWS_FLOAT(r3, r2);
	if (fabsf(r2[0]) > fabsf(r1[0])) SWAP_ROWS_FLOAT(r2, r1);
	if (fabsf(r1[0]) > fabsf(r0[0])) SWAP_ROWS_FLOAT(r1, r0);
	if (0.0 == r0[0]) return 0;
	
	/* eliminate first variable     */
	m1 = r1[0] / r0[0];
	m2 = r2[0] / r0[0];
	m3 = r3[0] / r0[0];
	s = r0[1];
	r1[1] -= m1 * s;
	r2[1] -= m2 * s;
	r3[1] -= m3 * s;
	s = r0[2];
	r1[2] -= m1 * s;
	r2[2] -= m2 * s;
	r3[2] -= m3 * s;
	s = r0[3];
	r1[3] -= m1 * s;
	r2[3] -= m2 * s;
	r3[3] -= m3 * s;
	s = r0[4];
	if (s != 0.0) {
		r1[4] -= m1 * s;
		r2[4] -= m2 * s;
		r3[4] -= m3 * s;
	}
	s = r0[5];
	if (s != 0.0) {
		r1[5] -= m1 * s;
		r2[5] -= m2 * s;
		r3[5] -= m3 * s;
	}
	s = r0[6];
	if (s != 0.0) {
		r1[6] -= m1 * s;
		r2[6] -= m2 * s;
		r3[6] -= m3 * s;
	}
	s = r0[7];
	if (s != 0.0) {
		r1[7] -= m1 * s;
		r2[7] -= m2 * s;
		r3[7] -= m3 * s;
	}
	
	/* choose pivot - or die */
	if (fabsf(r3[1]) > fabsf(r2[1])) SWAP_ROWS_FLOAT(r3, r2);
	if (fabsf(r2[1]) > fabsf(r1[1])) SWAP_ROWS_FLOAT(r2, r1);
	if (0.0 == r1[1]) return 0;
	
	/* eliminate second variable */
	m2 = r2[1] / r1[1];
	m3 = r3[1] / r1[1];
	r2[2] -= m2 * r1[2];
	r3[2] -= m3 * r1[2];
	r2[3] -= m2 * r1[3];
	r3[3] -= m3 * r1[3];
	s = r1[4];
	if (0.0 != s) {
		r2[4] -= m2 * s;
		r3[4] -= m3 * s;
	}
	s = r1[5];
	if (0.0 != s) {
		r2[5] -= m2 * s;
		r3[5] -= m3 * s;
	}
	s = r1[6];
	if (0.0 != s) {
		r2[6] -= m2 * s;
		r3[6] -= m3 * s;
	}
	s = r1[7];
	if (0.0 != s) {
		r2[7] -= m2 * s;
		r3[7] -= m3 * s;
	}
	
	/* choose pivot - or die */
	if (fabsf(r3[2]) > fabsf(r2[2])) SWAP_ROWS_FLOAT(r3, r2);
	if (0.0 == r2[2]) return 0;
	
	/* eliminate third variable */
	m3 = r3[2] / r2[2];
	r3[3] -= m3 * r2[3], r3[4] -= m3 * r2[4],
	r3[5] -= m3 * r2[5], r3[6] -= m3 * r2[6], r3[7] -= m3 * r2[7];
	
	/* last check */
	if (0.0 == r3[3]) return 0;
	
	s = 1.0 / r3[3];		/* now back substitute row 3 */
	r3[4] *= s;
	r3[5] *= s;
	r3[6] *= s;
	r3[7] *= s;
	m2 = r2[3];			/* now back substitute row 2 */
	s = 1.0 / r2[2];
	r2[4] = s * (r2[4] - r3[4] * m2), r2[5] = s * (r2[5] - r3[5] * m2),
	r2[6] = s * (r2[6] - r3[6] * m2), r2[7] = s * (r2[7] - r3[7] * m2);
	m1 = r1[3];
	r1[4] -= r3[4] * m1, r1[5] -= r3[5] * m1,
	r1[6] -= r3[6] * m1, r1[7] -= r3[7] * m1;
	m0 = r0[3];
	r0[4] -= r3[4] * m0, r0[5] -= r3[5] * m0,
	r0[6] -= r3[6] * m0, r0[7] -= r3[7] * m0;
	m1 = r1[2];			/* now back substitute row 1 */
	s = 1.0 / r1[1];
	r1[4] = s * (r1[4] - r2[4] * m1), r1[5] = s * (r1[5] - r2[5] * m1),
	r1[6] = s * (r1[6] - r2[6] * m1), r1[7] = s * (r1[7] - r2[7] * m1);
	m0 = r0[2];
	r0[4] -= r2[4] * m0, r0[5] -= r2[5] * m0,
	r0[6] -= r2[6] * m0, r0[7] -= r2[7] * m0;
	m0 = r0[1];			/* now back substitute row 0 */
	s = 1.0 / r0[0];
	r0[4] = s * (r0[4] - r1[4] * m0), r0[5] = s * (r0[5] - r1[5] * m0),
	r0[6] = s * (r0[6] - r1[6] * m0), r0[7] = s * (r0[7] - r1[7] * m0);
	MAT(out, 0, 0) = r0[4];
	MAT(out, 0, 1) = r0[5], MAT(out, 0, 2) = r0[6];
	MAT(out, 0, 3) = r0[7], MAT(out, 1, 0) = r1[4];
	MAT(out, 1, 1) = r1[5], MAT(out, 1, 2) = r1[6];
	MAT(out, 1, 3) = r1[7], MAT(out, 2, 0) = r2[4];
	MAT(out, 2, 1) = r2[5], MAT(out, 2, 2) = r2[6];
	MAT(out, 2, 3) = r2[7], MAT(out, 3, 0) = r3[4];
	MAT(out, 3, 1) = r3[5], MAT(out, 3, 2) = r3[6];
	MAT(out, 3, 3) = r3[7];
	
	return 1;
}

#pragma mark -
#pragma mark Matrix Inverse (Oolong Engine Version. WARNING!! Can't Handle Projective Matrix)
#pragma mark -

void EISMatrix4x4OolongInverse(EISMatrix4x4 mat, EISMatrix4x4 inverted) {
	
	double			pos;
	double			neg;
	double			temp;
	EISMatrix4x4	scratch;
	
	// Calculate the determinant of submatrix A and determine if the the matrix 
	// is singular as limited by the double precision floating-point data representation.
    pos = neg = 0.0;
    temp =  mat[ 0] * mat[ 5] * mat[10];
    if (temp >= 0.0) pos += temp; else neg += temp;
	
    temp =  mat[ 4] * mat[ 9] * mat[ 2];
    if (temp >= 0.0) pos += temp; else neg += temp;
	
    temp =  mat[ 8] * mat[ 1] * mat[ 6];
    if (temp >= 0.0) pos += temp; else neg += temp;
	
    temp = -mat[ 8] * mat[ 5] * mat[ 2];
    if (temp >= 0.0) pos += temp; else neg += temp;
	
    temp = -mat[ 4] * mat[ 1] * mat[10];
    if (temp >= 0.0) pos += temp; else neg += temp;
	
    temp = -mat[ 0] * mat[ 9] * mat[ 6];
    if (temp >= 0.0) pos += temp; else neg += temp;
	
	
	double determinant = pos + neg;
	
	// Is the sub matrix singular?
    if ((determinant == 0.0) || (EISAbs(determinant / (pos - neg)) < 1.0e-15)) {
		
        /* Matrix M has no inverse */
        printf("Matrix has no inverse : singular matrix\n");
        return;
		
    } else {
		
        /* Calculate inverse(A) = adj(A) / det(A) */
        determinant = 1.0 / determinant;
        scratch[ 0] =   ( mat[ 5] * mat[10] - mat[ 9] * mat[ 6] ) * (float)determinant;
        scratch[ 1] = - ( mat[ 1] * mat[10] - mat[ 9] * mat[ 2] ) * (float)determinant;
        scratch[ 2] =   ( mat[ 1] * mat[ 6] - mat[ 5] * mat[ 2] ) * (float)determinant;
        scratch[ 4] = - ( mat[ 4] * mat[10] - mat[ 8] * mat[ 6] ) * (float)determinant;
        scratch[ 5] =   ( mat[ 0] * mat[10] - mat[ 8] * mat[ 2] ) * (float)determinant;
        scratch[ 6] = - ( mat[ 0] * mat[ 6] - mat[ 4] * mat[ 2] ) * (float)determinant;
        scratch[ 8] =   ( mat[ 4] * mat[ 9] - mat[ 8] * mat[ 5] ) * (float)determinant;
        scratch[ 9] = - ( mat[ 0] * mat[ 9] - mat[ 8] * mat[ 1] ) * (float)determinant;
        scratch[10] =   ( mat[ 0] * mat[ 5] - mat[ 4] * mat[ 1] ) * (float)determinant;
		
        /* Calculate -C * inverse(A) */
        scratch[12] = - ( mat[12] * scratch[ 0] + mat[13] * scratch[ 4] + mat[14] * scratch[ 8] );
        scratch[13] = - ( mat[12] * scratch[ 1] + mat[13] * scratch[ 5] + mat[14] * scratch[ 9] );
        scratch[14] = - ( mat[12] * scratch[ 2] + mat[13] * scratch[ 6] + mat[14] * scratch[10] );
		
        /* Fill mat last row */
        scratch[ 3] = 0.0f;
		scratch[ 7] = 0.0f;
		scratch[11] = 0.0f;
        scratch[15] = 1.0f;
	}
	
	// Column 1
	inverted[_11] = scratch[_11];
	inverted[_12] = scratch[_12];
	inverted[_13] = scratch[_13];
	inverted[_14] = scratch[_14];
	
	// Column 2
	inverted[_21] = scratch[_21];
	inverted[_22] = scratch[_22];
	inverted[_23] = scratch[_23];
	inverted[_24] = scratch[_24];
	
	// Column 3
	inverted[_31] = scratch[_31];
	inverted[_32] = scratch[_32];
	inverted[_33] = scratch[_33];
	inverted[_34] = scratch[_34];
	
	// Column 4
	inverted[_41] = scratch[_41];
	inverted[_42] = scratch[_42];
	inverted[_43] = scratch[_43];
	inverted[_44] = scratch[_44];
	
}

#pragma mark -
#pragma mark Vector3D Transform (M * pt)
#pragma mark -

void EISMatrix4x4MultiplyEISVector3D(EISMatrix4x4 m4x4, EISVector3D point) {
	
	// This is from my render system. Read the matrix as m[columns][rows]
	float xform[4][3];
	
	// Stuff the matrix into my format
	xform[0][0] = MatrixElement(m4x4, 0, 0);
	xform[1][0] = MatrixElement(m4x4, 0, 1);
	xform[2][0] = MatrixElement(m4x4, 0, 2);
	xform[3][0] = MatrixElement(m4x4, 0, 3);
	
	xform[0][1] = MatrixElement(m4x4, 1, 0);
	xform[1][1] = MatrixElement(m4x4, 1, 1);
	xform[2][1] = MatrixElement(m4x4, 1, 2);
	xform[3][1] = MatrixElement(m4x4, 1, 3);
	
	xform[0][2] = MatrixElement(m4x4, 2, 0);
	xform[1][2] = MatrixElement(m4x4, 2, 1);
	xform[2][2] = MatrixElement(m4x4, 2, 2);
	xform[3][2] = MatrixElement(m4x4, 2, 3);
	
	float dst[3];
	EISAffineTransform(&point[0], &xform[0][0], &dst[0], 1, 3, 3);
	
	point[0] = dst[0];
	point[1] = dst[1];
	point[2] = dst[2];
}

/*******************************************************************************
 * Affine transformations, for transforming points in row vector form.
 *	ig[n][id]		- input
 *	mg[id+1][mo]	- matrix
 *	og[n][mo]		- output
 *
 * Examples:
 * p[3] * M[4][3] -> q[3]:	AffineTransform(&p[0], &M[0][0], &q[0], 1, 3, 3);
 ********************************************************************************/
void EISAffineTransform(float* ig, float* mg, float* og, int n, int id, int mo) {
	
    float* ip;
    float* mp;
	
    int k, j, i;
    float sum;
    for (i = n; i--; ig += id) {
		for (j = 0; j < mo; j++) {
			ip = ig;
			mp = mg + j;
			sum = 0;
			for (k = id; k--; mp += mo) sum += *ip++ * (*mp);
			*og++ = sum + *mp;
		}
    }
	
}
