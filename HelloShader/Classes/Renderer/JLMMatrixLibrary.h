//
//  JLMMatrixLibrary.h
//  HelloTeapot
//
//  Created by turner on 4/30/09.
//  Copyright 2009 Douglass Turner Consulting. All rights reserved.
//

#ifndef _JLM_MATRIX_LIBRARY_
#define _JLM_MATRIX_LIBRARY_

#include "VectorMatrix.h"

#ifdef __cplusplus
extern "C" {
#endif
	
// We will use the typedef from VectorMatrix.h	
//typedef float M3DMatrix44f[16];
	
//
// We assume matrix pre-multiplication:
// mat * pt = pt_transformed
// (B * A) * pt = pt_transformed
//
void JLMMatrix3DMultiply(M3DMatrix44f B, M3DMatrix44f A, M3DMatrix44f concatenation);

void JLMMatrix3DSetIdentity(M3DMatrix44f matrix);

void JLMMatrix3DSetTranslation(M3DMatrix44f matrix, float xTranslate, float yTranslate, float zTranslate);

void JLMMatrix3DSetScaling(M3DMatrix44f matrix, float xScale, float yScale, float zScale);

void JLMMatrix3DSetUniformScaling(M3DMatrix44f matrix, float scale);

void JLMMatrix3DSetXRotationUsingRadians(M3DMatrix44f matrix, float degrees);
void JLMMatrix3DSetXRotationUsingDegrees(M3DMatrix44f matrix, float degrees);

void JLMMatrix3DSetYRotationUsingRadians(M3DMatrix44f matrix, float degrees);
void JLMMatrix3DSetYRotationUsingDegrees(M3DMatrix44f matrix, float degrees);

void JLMMatrix3DSetZRotationUsingRadians(M3DMatrix44f matrix, float degrees);
void JLMMatrix3DSetZRotationUsingDegrees(M3DMatrix44f matrix, float degrees);

void JLMMatrix3DSetRotationByRadians(M3DMatrix44f matrix, float angle, float x, float y, float z);
void JLMMatrix3DSetRotationByDegrees(M3DMatrix44f matrix, float angle, float x, float y, float z);
	
void OolongMatrixInverse(M3DMatrix44f mat, M3DMatrix44f inverted);
	
	
#ifdef __cplusplus
}
#endif

#endif
