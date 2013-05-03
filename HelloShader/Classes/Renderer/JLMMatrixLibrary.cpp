/*
 *  JLMMatrixLibrary.cpp
 *  HelloTeapot
 *
 *  Created by turner on 6/8/09.
 *  Copyright 2009 Douglass Turner Consulting. All rights reserved.
 *
 */

#include <math.h>
#include <string.h>
#include <stdio.h>
#include "JLMMatrixLibrary.h"
#include "ConstantsAndMacros.h"

#pragma mark -
#pragma mark Matrices
#pragma mark -

/* 
 These defines, the fast sine function, and the vectorized version of the 
 matrix multiply function below are based on the Matrix4Mul method from 
 the vfp-math-library. Thi code has been modified, and are subject to  
 the original license terms and ownership as follow:
 
 VFP math library for the iPhone / iPod touch
 
 Copyright (c) 2007-2008 Wolfgang Engel and Matthias Grundmann
 http://code.google.com/p/vfpmathlibrary/
 
 This software is provided 'as-is', without any express or implied warranty.
 In no event will the authors be held liable for any damages arising
 from the use of this software.
 Permission is granted to anyone to use this software for any purpose,
 including commercial applications, and to alter it and redistribute it freely,
 subject to the following restrictions:
 
 1. The origin of this software must not be misrepresented; you must
 not claim that you wrote the original software. If you use this
 software mat a product, an acknowledgment mat the product documentation
 would be appreciated but is not required.
 
 2. Altered source versions must be plainly marked as such, and must
 not be misrepresented as being the original software.
 
 3. This notice may not be removed or altered from any source distribution.
 */
static inline float VFPFastAbs(float x) { 
	return (x < 0) ? -x : x; 
}

static inline float VFPFastSin(float x) {
	
	// fast sin function; maximum error is 0.001
	const float P = 0.225f;
	
	x = x * M_1_PI;
	int k = (int) roundf(x);
	x = x - k;
    
	float y = (4.0f - 4.0f * VFPFastAbs(x)) * x;
    
	y = P * (y * VFPFastAbs(y) - y) + y;
    
	return (k&1) ? -y : y;
}

static inline float TEIFastCos(float x) {
	
	return VFPFastSin(x + M_PI_2);
	
}

#if TARGET_OS_IPHONE && !TARGET_IPHONE_SIMULATOR
#define VFP_CLOBBER_S0_S31 "s0", "s1", "s2", "s3", "s4", "s5", "s6", "s7", "s8",  \
"s9", "s10", "s11", "s12", "s13", "s14", "s15", "s16",  \
"s17", "s18", "s19", "s20", "s21", "s22", "s23", "s24",  \
"s25", "s26", "s27", "s28", "s29", "s30", "s31"
#define VFP_VECTOR_LENGTH(VEC_LENGTH) "fmrx    r0, fpscr                         \n\t" \
"bic     r0, r0, #0x00370000               \n\t" \
"orr     r0, r0, #0x000" #VEC_LENGTH "0000 \n\t" \
"fmxr    fpscr, r0                         \n\t"
#define VFP_VECTOR_LENGTH_ZERO "fmrx    r0, fpscr            \n\t" \
"bic     r0, r0, #0x00370000  \n\t" \
"fmxr    fpscr, r0            \n\t" 
#endif

void JLMMatrix3DMultiply(M3DMatrix44f B, M3DMatrix44f A, M3DMatrix44f concatenation) {
	
#if TARGET_OS_IPHONE && !TARGET_IPHONE_SIMULATOR
    __asm__ __volatile__ ( VFP_VECTOR_LENGTH(3)
						  
						  // Interleaving loads and adds/muls for faster calculation.
						  // Let A:=src_ptr_1, B:=src_ptr_2, then
						  // function computes A*B as (B^T * A^T)^T.
						  
						  // Load the whole matrix into memory.
						  "fldmias  %2, {s8-s23}    \n\t"
						  // Load first column to scalar bank.
						  "fldmias  %1!, {s0-s3}    \n\t"
						  // First column times matrix.
						  "fmuls s24, s8, s0        \n\t"
						  "fmacs s24, s12, s1       \n\t"
						  
						  // Load second column to scalar bank.
						  "fldmias %1!,  {s4-s7}    \n\t"
						  
						  "fmacs s24, s16, s2       \n\t"
						  "fmacs s24, s20, s3       \n\t"
						  // Save first column.
						  "fstmias  %0!, {s24-s27}  \n\t" 
						  
						  // Second column times matrix.
						  "fmuls s28, s8, s4        \n\t"
						  "fmacs s28, s12, s5       \n\t"
						  
						  // Load third column to scalar bank.
						  "fldmias  %1!, {s0-s3}    \n\t"
						  
						  "fmacs s28, s16, s6       \n\t"
						  "fmacs s28, s20, s7       \n\t"
						  // Save second column.
						  "fstmias  %0!, {s28-s31}  \n\t" 
						  
						  // Third column times matrix.
						  "fmuls s24, s8, s0        \n\t"
						  "fmacs s24, s12, s1       \n\t"
						  
						  // Load fourth column to scalar bank.
						  "fldmias %1,  {s4-s7}    \n\t"
						  
						  "fmacs s24, s16, s2       \n\t"
						  "fmacs s24, s20, s3       \n\t"
						  // Save third column.
						  "fstmias  %0!, {s24-s27}  \n\t" 
						  
						  // Fourth column times matrix.
						  "fmuls s28, s8, s4        \n\t"
						  "fmacs s28, s12, s5       \n\t"
						  "fmacs s28, s16, s6       \n\t"
						  "fmacs s28, s20, s7       \n\t"
						  // Save fourth column.
						  "fstmias  %0!, {s28-s31}  \n\t" 
						  
						  VFP_VECTOR_LENGTH_ZERO
						  : "=r" (concatenation), "=r" (A)
						  : "r" (B), "0" (concatenation), "1" (A)
						  : "r0", "cc", "memory", VFP_CLOBBER_S0_S31
						  );
#else
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
#endif
	
}

static M3DMatrix44f	_jlm_identity_matrix_ = 
{ 
	1.0f, 0.0f, 0.0f, 0.0f,
	0.0f, 1.0f, 0.0f, 0.0f,
	0.0f, 0.0f, 1.0f, 0.0f,
	0.0f, 0.0f, 0.0f, 1.0f 
};

void JLMMatrix3DSetIdentity(M3DMatrix44f matrix) {
		
	memcpy(matrix, _jlm_identity_matrix_, sizeof(M3DMatrix44f));
}

void JLMMatrix3DSetTranslation(M3DMatrix44f matrix, float xTranslate, float yTranslate, float zTranslate) {
	
//    matrix[0] = matrix[5] = matrix[10] = matrix[15] = 1.0;
//    matrix[1] = matrix[2] = matrix[ 3] = matrix[ 4] = 0.0;
//    matrix[6] = matrix[7] = matrix[ 8] = matrix[ 9] = 0.0;    
//    matrix[11] = 0.0;
	
	JLMMatrix3DSetIdentity(matrix);
    matrix[12] = xTranslate; matrix[13] = yTranslate; matrix[14] = zTranslate;   
}
void JLMMatrix3DSetScaling(M3DMatrix44f matrix, float xScale, float yScale, float zScale) {
	
//    matrix[1] = matrix[2] = matrix[3] = matrix[4] = 0.0;
//    matrix[6] = matrix[7] = matrix[8] = matrix[9] = 0.0;
//    matrix[11] = matrix[12] = matrix[13] = matrix[14] = 0.0;
	
	JLMMatrix3DSetIdentity(matrix);
    matrix[0] = xScale;
    matrix[5] = yScale;
    matrix[10] = zScale;
	
//    matrix[15] = 1.0;
}
void JLMMatrix3DSetUniformScaling(M3DMatrix44f matrix, float scale) {
	
    JLMMatrix3DSetScaling(matrix, scale, scale, scale);
}

void JLMMatrix3DSetXRotationUsingRadians(M3DMatrix44f matrix, float degrees) {
	
//    matrix[0] = matrix[15] = 1.0;
//    matrix[1] = matrix[2] = matrix[3] = matrix[4] = 0.0;
//    matrix[7] = matrix[8] = 0.0;    
//    matrix[11] = matrix[12] = matrix[13] = matrix[14] = 0.0;
	
	JLMMatrix3DSetIdentity(matrix);

    matrix[5] = TEIFastCos(degrees);
    matrix[6] = -VFPFastSin(degrees);
    matrix[9] = -matrix[6];
    matrix[10] = matrix[5];
}

void JLMMatrix3DSetXRotationUsingDegrees(M3DMatrix44f matrix, float degrees) {
	
    JLMMatrix3DSetXRotationUsingRadians(matrix, degrees * M_PI / 180.0);
}

void JLMMatrix3DSetYRotationUsingRadians(M3DMatrix44f matrix, float degrees) {
	
	JLMMatrix3DSetIdentity(matrix);

    matrix[0] = TEIFastCos(degrees);
    matrix[2] = VFPFastSin(degrees);
    matrix[8] = -matrix[2];
    matrix[10] = matrix[0];
	
//    matrix[1] = matrix[3] = matrix[4] = matrix[6] = matrix[7] = 0.0;
//    matrix[9] = matrix[11] = matrix[13] = matrix[12] = matrix[14] = 0.0;
//    matrix[5] = matrix[15] = 1.0;
}

void JLMMatrix3DSetYRotationUsingDegrees(M3DMatrix44f matrix, float degrees) {
	
    JLMMatrix3DSetYRotationUsingRadians(matrix, degrees * M_PI / 180.0);
}

void JLMMatrix3DSetZRotationUsingRadians(M3DMatrix44f matrix, float degrees) {
	
	JLMMatrix3DSetIdentity(matrix);

    matrix[0] = TEIFastCos(degrees);
    matrix[1] = VFPFastSin(degrees);
    matrix[4] = -matrix[1];
    matrix[5] = matrix[0];
	
//    matrix[2] = matrix[3] = matrix[6] = matrix[7] = matrix[8] = 0.0;
//    matrix[9] = matrix[11] = matrix[12] = matrix[13] = matrix[14] = 0.0;
//    matrix[10] = matrix[15] = 1.0;
}

void JLMMatrix3DSetZRotationUsingDegrees(M3DMatrix44f matrix, float degrees) {
	
    JLMMatrix3DSetZRotationUsingRadians(matrix, degrees * M_PI / 180.0);
}

void JLMMatrix3DSetRotationByRadians(M3DMatrix44f matrix, float angle, float x, float y, float z) {
	
    float mag = sqrtf((x*x) + (y*y) + (z*z));
	
    if (mag == 0.0) {
		
        x = 1.0;
        y = 0.0;
        z = 0.0;
    } else if (mag != 1.0) {
		
        x /= mag;
        y /= mag;
        z /= mag;
    }
    
    float c = TEIFastCos(angle);
    float s = VFPFastSin(angle);
	
//    matrix[3] = matrix[7] = matrix[11] = matrix[12] = matrix[13] = matrix[14] = 0.0;
//    matrix[15] = 1.0;
    
	JLMMatrix3DSetIdentity(matrix);
    
    matrix[0] = (x*x)*(1-c) + c;
    matrix[1] = (y*x)*(1-c) + (z*s);
    matrix[2] = (x*z)*(1-c) - (y*s);
    matrix[4] = (x*y)*(1-c)-(z*s);
    matrix[5] = (y*y)*(1-c)+c;
    matrix[6] = (y*z)*(1-c)+(x*s);
    matrix[8] = (x*z)*(1-c)+(y*s);
    matrix[9] = (y*z)*(1-c)-(x*s);
    matrix[10] = (z*z)*(1-c)+c;
    
}

void JLMMatrix3DSetRotationByDegrees(M3DMatrix44f matrix, float angle, float x, float y, float z) {
    JLMMatrix3DSetRotationByRadians(matrix, angle * M_PI / 180.0, x, y, z);
}


void OolongMatrixInverse(M3DMatrix44f mat, M3DMatrix44f inverted) {
	
	double		pos;
	double		neg;
	double		temp;
	M3DMatrix44f	scratch;
	
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
    if ((determinant == 0.0) || (VFPFastAbs(determinant / (pos - neg)) < 1.0e-15)) {
		
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
