/*
 *  VectorMatrix.cpp
 *  HelloTeapot
 *
 *  Created by turner on 4/30/09.
 *  Copyright 2009 Douglass Turner Consulting. All rights reserved.
 *
 */

#include <math.h>
#include <memory.h>
#include <stdio.h>
#include "VectorMatrix.h"
#include "ConstantsAndMacros.h"

void m3dLoadVector2f(M3DVector2f v, float x, float y) { 
	v[0] = x; 
	v[1] = y; 
}

void m3dLoadVector3f(M3DVector3f v, float x, float y, float z) { 
	v[0] = x; 
	v[1] = y; 
	v[2] = z; 
}

// Copy vector src into vector dst
void m3dCopyVector2f(M3DVector2f dst, M3DVector2f src) { 
	memcpy(dst, src, sizeof(M3DVector2f)); 
}

void m3dCopyVector3f(M3DVector3f dst, M3DVector3f src) { 
	memcpy(dst, src, sizeof(M3DVector3f)); 
}

// Add Vectors (r, a, b) r = a + b
void m3dAddVectors2f(M3DVector2f r, M3DVector2f a, M3DVector2f b) { 
	r[0] = a[0] + b[0];	
	r[1] = a[1] + b[1];  
}

void m3dAddVectors3f(M3DVector3f r, M3DVector3f a, M3DVector3f b) { 
	r[0] = a[0] + b[0];	
	r[1] = a[1] + b[1]; 
	r[2] = a[2] + b[2]; 
}

// Subtract Vectors (r, a, b) r = a - b
void m3dSubtractVectors2f(M3DVector2f r, M3DVector2f a, M3DVector2f b) { 
	r[0] = a[0] - b[0]; 
	r[1] = a[1] - b[1];  
}

void m3dSubtractVectors3f(M3DVector3f r, M3DVector3f a, M3DVector3f b) { 
	r[0] = a[0] - b[0]; 
	r[1] = a[1] - b[1]; 
	r[2] = a[2] - b[2];
}

// Scale Vectors (in place)
void m3dScaleVector2f(M3DVector2f v, float scale) { 
	v[0] *= scale; 
	v[1] *= scale; 
}

void m3dScaleVector3f(M3DVector3f v, float scale) { 
	v[0] *= scale; 
	v[1] *= scale; 
	v[2] *= scale; 
}

// Cross Product u x v = result
void m3dCrossProductf(M3DVector3f result, M3DVector3f u, M3DVector3f v) {
	result[0] =  u[1]*v[2] - v[1]*u[2];
	result[1] = -u[0]*v[2] + v[0]*u[2];
	result[2] =  u[0]*v[1] - v[0]*u[1];
}

// Dot Product returns u dot v
float m3dDotProductf(M3DVector3f u, M3DVector3f v) { 
	return u[0]*v[0] + u[1]*v[1] + u[2]*v[2]; 
}

float m3dGetAngleBetweenVectorsf(M3DVector3f u, M3DVector3f v) {
	
    float dot = m3dDotProductf(u, v);
    return acosf(dot);
}

float m3dGetVectorLengthf(M3DVector3f u) { 
	return sqrtf(m3dGetVectorLengthSquaredf(u)); 
}

float m3dGetVectorLengthSquaredf(M3DVector3f u) { 
	return (u[0] * u[0]) + (u[1] * u[1]) + (u[2] * u[2]); 
}

void m3dNormalizeVectorf(M3DVector3f u) { 
	m3dScaleVector3f(u, 1.0f / m3dGetVectorLengthf(u)); 
}

void m3dCopyMatrix44f(M3DMatrix44f dst, M3DMatrix44f src) { 
	memcpy(dst, src, sizeof(M3DMatrix44f)); 
}

void m3dLoadIdentity44f(M3DMatrix44f m) {
	
	static M3DMatrix44f	identity = 
	{ 
		1.0f, 0.0f, 0.0f, 0.0f,
		0.0f, 1.0f, 0.0f, 0.0f,
		0.0f, 0.0f, 1.0f, 0.0f,
		0.0f, 0.0f, 0.0f, 1.0f 
	};
	
	memcpy(m, identity, sizeof(M3DMatrix44f));
}

void TIEEchoMatrix4x4(M3DMatrix44f m) {

	printf("%.4f %.4f %.4f %.4f\n", m[_11], m[_21], m[_31], m[_41]);
	printf("%.4f %.4f %.4f %.4f\n", m[_12], m[_22], m[_32], m[_42]);
	printf("%.4f %.4f %.4f %.4f\n", m[_13], m[_23], m[_33], m[_43]);
	printf("%.4f %.4f %.4f %.4f\n", m[_14], m[_24], m[_34], m[_44]);
}

void TIEMatrix4x4MulPoint3(M3DMatrix44f m4x4, M3DVector3f point) {

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
	TIEAffineTransform(&point[0], &xform[0][0], &dst[0], 1, 3, 3);
	
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
void TIEAffineTransform(float* ig, float* mg, float* og, int n, int id, int mo) {
	
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

void TIESetRotationX(float* m4x4, float radians) {
	
	m3dLoadIdentity44f(m4x4);
		
    float s		= sinf(radians); 
    float c		= cosf(radians);	
	
	// This is from my render system. Read the matrix as m[columns][rows]
	float xform[3][3];

    xform[0][0] = 1;	xform[0][1] =  0;	xform[0][2] = 0;
    xform[1][0] = 0;	xform[1][1] =  c;	xform[1][2] = s;
    xform[2][0] = 0;	xform[2][1] = -s;	xform[2][2] = c;
	
	// Stuff the matrix into my format
	MatrixElement(m4x4, 0, 0) = xform[0][0];
	MatrixElement(m4x4, 0, 1) = xform[1][0];
	MatrixElement(m4x4, 0, 2) = xform[2][0];
	
	MatrixElement(m4x4, 1, 0) = xform[0][1];
	MatrixElement(m4x4, 1, 1) = xform[1][1];
	MatrixElement(m4x4, 1, 2) = xform[2][1];
	
	MatrixElement(m4x4, 2, 0) = xform[0][2];
	MatrixElement(m4x4, 2, 1) = xform[1][2];
	MatrixElement(m4x4, 2, 2) = xform[2][2];
	
}

void TIESetRotationY(float* m4x4, float radians) {
	
	m3dLoadIdentity44f(m4x4);
	
    float s		= sinf(radians); 
    float c		= cosf(radians);	
	
	// This is from my render system. Read the matrix as m[columns][rows]
	float xform[3][3];
	
    xform[0][0] = c;	xform[0][1] = 0;	xform[0][2] = -s;
    xform[1][0] = 0;	xform[1][1] = 1;	xform[1][2] =  0;
    xform[2][0] = s;	xform[2][1] = 0;	xform[2][2] =  c;
	
	// Stuff the matrix into my format
	MatrixElement(m4x4, 0, 0) = xform[0][0];
	MatrixElement(m4x4, 0, 1) = xform[1][0];
	MatrixElement(m4x4, 0, 2) = xform[2][0];
	
	MatrixElement(m4x4, 1, 0) = xform[0][1];
	MatrixElement(m4x4, 1, 1) = xform[1][1];
	MatrixElement(m4x4, 1, 2) = xform[2][1];
	
	MatrixElement(m4x4, 2, 0) = xform[0][2];
	MatrixElement(m4x4, 2, 1) = xform[1][2];
	MatrixElement(m4x4, 2, 2) = xform[2][2];
	
}

void TIESetRotationZ(float* m4x4, float radians) {
	
	m3dLoadIdentity44f(m4x4);
	
    float s		= sinf(radians); 
    float c		= cosf(radians);	
	
	// This is from my render system. Read the matrix as m[columns][rows]
	float xform[3][3];
	
    xform[0][0] =  c;	xform[0][1] = s;	xform[0][2] = 0;
    xform[1][0] = -s;	xform[1][1] = c;	xform[1][2] = 0;
    xform[2][0] =  0;	xform[2][1] = 0;	xform[2][2] = 1;
	
	// Stuff the matrix into my format
	MatrixElement(m4x4, 0, 0) = xform[0][0];
	MatrixElement(m4x4, 0, 1) = xform[1][0];
	MatrixElement(m4x4, 0, 2) = xform[2][0];
	
	MatrixElement(m4x4, 1, 0) = xform[0][1];
	MatrixElement(m4x4, 1, 1) = xform[1][1];
	MatrixElement(m4x4, 1, 2) = xform[2][1];
	
	MatrixElement(m4x4, 2, 0) = xform[0][2];
	MatrixElement(m4x4, 2, 1) = xform[1][2];
	MatrixElement(m4x4, 2, 2) = xform[2][2];
	
}



