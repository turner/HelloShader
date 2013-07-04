/*
 *  EISVectorMatrix.h
 *
 *  Created by Douglass Turner on 12/1/10.
 *  Copyright 2010 Elastic Image Software LLC. All rights reserved.
 *
 */

#ifndef _EIS_VECTOR_MATRIX_
#define _EIS_VECTOR_MATRIX_

#include <CoreGraphics/CGGeometry.h>

#define EIS_2PI (2.0 * M_PI)
#define EIS_PI_DIV_180 (0.017453292519943296)
#define EIS_INV_PI_DIV_180 (57.2957795130823229)

#define EISDegreeToRadian(x)	((x) *     EIS_PI_DIV_180)
#define EISRadianToDegree(x)	((x) * EIS_INV_PI_DIV_180)


// Handy for 4x4 matrices
#define _11 0
#define _12 1
#define _13 2
#define _14 3
#define _21 4
#define _22 5
#define _23 6
#define _24 7
#define _31 8
#define _32 9
#define _33 10
#define _34 11
#define _41 12
#define _42 13
#define _43 14
#define _44 15

// Handy for 3D vectors
#define _X 0
#define _Y 1
#define _Z 2

#define MatrixElement(m, row, column)  (m[(column * 4) + row])

typedef float EISVector3D[3];

// 4x4 matrix - column major. X vector is 0, 1, 2, etc.
//	0	4	8	12
//	1	5	9	13
//	2	6	10	14
//	3	7	11	15
typedef float EISMatrix4x4[16];

#ifdef __cplusplus
extern "C" {
#endif
	
	// Load Vector with (x, y, z).
	void EISVector3DSet(EISVector3D v, float x, float y, float z);
	
	// Copy vector src into vector dst
	void EISVector3DCopy(EISVector3D dst, EISVector3D src);
	
	// Add Vectors (r, a, b) r = a + b
	void EISVector3DAdd(EISVector3D r, EISVector3D a, EISVector3D b);
	
	// Subtract Vectors (r, a, b) r = a - b
	void EISVector3DSubtract(EISVector3D r, EISVector3D a, EISVector3D b);
	
	// Scale Vectors (in place)
	void EISVector3DScale(EISVector3D v, float scale);
	
	// Cross Product u x v = result
	void EISVector3DCrossProduct(EISVector3D result, EISVector3D u, EISVector3D v);
	
	// Dot Product returns u dot v
	float EISVector3DDotProduct(EISVector3D u, EISVector3D v);
	
	// Angle between vectors
	float EISVector3DAngleBetween(EISVector3D u, EISVector3D v);
	
	// Get length of vector
	float EISVector3DLength(EISVector3D u);
	float m3dGetVectorLengthSquaredf(EISVector3D u);
	
	// Scale a vector to unit length.
	void EISVector3DNormalize(EISVector3D u);
	
	//
	// We assume matrix pre-multiplication:
	// mat * pt = pt_transformed
	// (B * A) * pt = pt_transformed
	//
	void EISMatrix4x4Multiply(EISMatrix4x4 B, EISMatrix4x4 A, EISMatrix4x4 concatenation);
	
	// B * A -> A'
	void EISConcatenate(EISMatrix4x4 B, EISMatrix4x4 A);
	
	void EISMatrix4x4SetIdentity(EISMatrix4x4 matrix);
	
	void EISMatrix4x4Set(EISMatrix4x4 dst, EISMatrix4x4 src);
	
	void EISMatrix4x4SetTranslation(EISMatrix4x4 matrix, float xTranslate, float yTranslate, float zTranslate);
	
	void EISMatrix4x4SetScaling(EISMatrix4x4 matrix, float xScale, float yScale, float zScale);
	
	void EISMatrix4x4SetUniformScaling(EISMatrix4x4 matrix, float scale);
	
	void EISMatrix4x4SetXRotationUsingRadians(EISMatrix4x4 matrix, float rad);
	void EISMatrix4x4SetXRotationUsingDegrees(EISMatrix4x4 matrix, float deg);
	
	void EISMatrix4x4SetYRotationUsingRadians(EISMatrix4x4 matrix, float rad);
	void EISMatrix4x4SetYRotationUsingDegrees(EISMatrix4x4 matrix, float deg);
	
	void EISMatrix4x4SetZRotationUsingRadians(EISMatrix4x4 matrix, float rad);
	void EISMatrix4x4SetZRotationUsingDegrees(EISMatrix4x4 matrix, float deg);

	void EISUIViewToWorldSpaceRay (CGPoint inScreenSpace, float *projViewModel, CGSize viewportSize, EISMatrix4x4 inWorldSpace);
		
	int EISMatrix4x4Inverse(float *m, float *out);

	void EISMatrix4x4OolongInverse(EISMatrix4x4 mat, EISMatrix4x4 inverted);

	void EISMatrix4x4MultiplyEISVector3D(EISMatrix4x4 m4x4, EISVector3D point);
	void EISAffineTransform(float* ig, float* mg, float* og, int n, int id, int mo);
	
#ifdef __cplusplus
}
#endif

#endif

