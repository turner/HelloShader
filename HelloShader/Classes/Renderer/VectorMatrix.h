/*
 *  VectorMatrix.h
 *  HelloTeapot
 *
 *  Created by turner on 4/30/09.
 *  Copyright 2009 Douglass Turner Consulting. All rights reserved.
 *
 */

#ifndef _VECTOR_MATRIX_
#define _VECTOR_MATRIX_

#ifdef __cplusplus
extern "C" {
#endif
	
typedef float M3DVector3f[3];
typedef float M3DVector2f[2];

// 4x4 matrix - column major. X vector is 0, 1, 2, etc.
//	0	4	8	12
//	1	5	9	13
//	2	6	10	14
//	3	7	11	15
typedef float M3DMatrix44f[16];

#define MatrixElement(m, row, column)  (m[(column * 4) + row])

// Load Vector with (x, y, z).
void m3dLoadVector2f(M3DVector2f v, float x, float y);
void m3dLoadVector3f(M3DVector3f v, float x, float y, float z);

// Copy vector src into vector dst
void m3dCopyVector2f(M3DVector2f dst, M3DVector2f src);
void m3dCopyVector3f(M3DVector3f dst, M3DVector3f src);

// Add Vectors (r, a, b) r = a + b
void m3dAddVectors2f(M3DVector2f r, M3DVector2f a, M3DVector2f b);
void m3dAddVectors3f(M3DVector3f r, M3DVector3f a, M3DVector3f b);

// Subtract Vectors (r, a, b) r = a - b
void m3dSubtractVectors2f(M3DVector2f r, M3DVector2f a, M3DVector2f b);
void m3dSubtractVectors3f(M3DVector3f r, M3DVector3f a, M3DVector3f b);

// Scale Vectors (in place)
void m3dScaleVector2f(M3DVector2f v, float scale);
void m3dScaleVector3f(M3DVector3f v, float scale);

// Cross Product u x v = result
void m3dCrossProductf(M3DVector3f result, M3DVector3f u, M3DVector3f v);

// Dot Product returns u dot v
float m3dDotProductf(M3DVector3f u, M3DVector3f v);

// Angle between vectors, only for three component vectors. Angle is in radians...
float m3dGetAngleBetweenVectorsf(M3DVector3f u, M3DVector3f v);

// Get length of vector
float m3dGetVectorLengthf(M3DVector3f u);
float m3dGetVectorLengthSquaredf(M3DVector3f u);

// Scale a vector to unit length.
void m3dNormalizeVectorf(M3DVector3f u);

// Copy Matrix
void m3dCopyMatrix44f(M3DMatrix44f dst, M3DMatrix44f src);
	
// LoadIdentity
void m3dLoadIdentity44f(M3DMatrix44f m);
	
// Echo Matrix
void TIEEchoMatrix4x4(M3DMatrix44f m);
	
// Transform a 3D point. We currently use vectors because I haven't implemented a point class yet
void TIEMatrix4x4MulPoint3(M3DMatrix44f m4x4, M3DVector3f point);
void TIEAffineTransform(float* ig, float* mg, float* og, int n, int id, int mo);
	
void TIESetRotationX(float* m4x4, float radians);
void TIESetRotationY(float* m4x4, float radians);
void TIESetRotationZ(float* m4x4, float radians);
		
#ifdef __cplusplus
}
#endif

#endif

