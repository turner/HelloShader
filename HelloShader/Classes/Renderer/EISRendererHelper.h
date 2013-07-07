//
//  EISRendererHelper.h
//
//  Created by turner on 3/4/10.
//  Copyright 2010 Douglass Turner Consulting. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import "EISVectorMatrix.h"

@interface EISRendererHelper : NSObject {

	EISVector3D		m_eye;
	EISVector3D		m_target;
	EISVector3D		m_up;
	
	EISMatrix4x4	m_projectionViewModelTransform;
	EISMatrix4x4	m_projectionViewTransform;
	EISMatrix4x4    m_viewModelTransform;

	EISMatrix4x4	m_projection;
	
	EISMatrix4x4	m_modelTransform;
	EISMatrix4x4	m_surfaceNormalTransform;
	
	EISMatrix4x4	m_scaleTransform;

	EISMatrix4x4	m_anchoredScaleTranslation;
	EISMatrix4x4	m_inverseAnchoredScaleTranslation;

	EISMatrix4x4	m_translationTransform;
	
	EISMatrix4x4	m_viewTransform;

	EISMatrix4x4	m_cameraTransform;

}

@property (nonatomic        ) CGSize				viewportSize;
@property (nonatomic, retain) NSMutableDictionary	*renderables;

// get/set eye
- (float *) eye; 
- (void) setEye:(EISVector3D)input; 
- (void) setEyeX:(float)x y:(float)y z:(float)z; 

// get/set target
- (float *) target; 
- (void) setTarget:(EISVector3D)input; 
- (void) setTargetX:(float)x y:(float)y z:(float)z; 

// get/set up
- (float *) up; 
- (void) setUp:(EISVector3D)input; 
- (void) setUpX:(float)x y:(float)y z:(float)z; 

- (float *) projectionViewModelTransform; 
- (void) setProjectionViewModelTransform:(EISMatrix4x4)input; 

- (float *) projectionViewTransform; 
- (void) setProjectionViewTransform:(EISMatrix4x4)input; 

- (float *) viewModelTransform; 
- (void) setViewModelTransform:(EISMatrix4x4)input; 

- (float *) projection; 
- (void) setProjection:(EISMatrix4x4)input; 

- (float *) modelTransform; 
- (void) setModelTransform:(EISMatrix4x4)input; 
- (float *) surfaceNormalTransform; 

- (float *) scaleTransform; 
- (void) setScaleTransform:(CGPoint)input; 

- (float *) anchoredScaleTranslation;
- (void) setAnchoredScaleTranslation:(CGPoint)input; 
- (float *) inverseAnchoredScaleTranslation; 

- (float *) translationTransform; 
- (void) setTranslationTransform:(CGPoint)input; 

- (float *) viewTransform; 
- (void) setViewTransform:(EISMatrix4x4)input; 

- (float *) cameraTransform;

- (void)setupProjectionViewModelTransformWithRenderSurfaceHalfSize:(CGSize)renderSurfaceHalfSize;

- (void)placeCameraAtLocation:(EISVector3D)location target:(EISVector3D)target up:(EISVector3D)up;

- (void)perspectiveProjectionWithFieldOfViewInDegreesY:(GLfloat)fieldOfViewInDegreesY 
							aspectRatioWidthOverHeight:(GLfloat)aspectRatioWidthOverHeight 
												  near:(GLfloat)near 
												   far:(GLfloat)far;

- (void)orthographicProjectionLeft:(GLfloat)left 
							 right:(GLfloat)right 
							   top:(GLfloat)top 
							bottom:(GLfloat)bottom 
							  near:(GLfloat)near 
							   far:(GLfloat)far;

+ (void) echoTransform:(EISMatrix4x4)transform;

+ (CGPoint) EricHainesSphericalInverseMappingSp:(EISVector3D)Sp 
											 Se:(EISVector3D)Se 
											 Sn:(EISVector3D)Sn;


+ (GLfloat *)verticesST;

+ (GLfloat *)verticesXYZ_Template;

+ (void) createQuadXYZ:(GLfloat *)quadXYZ halfSize:(CGSize)halfSize;

// Utility methods
+ (float) clampValue:(float)value lower:(float)lower upper:(float)upper;
+ (float) saturate:(float)value;
+ (float) smoothStepWithValue:(float)value lower:(float)lower upper:(float)upper;
+ (float) interpolateWithValue:(float)value from:(float)from to:(float)to;
+ (float) modWithValue:(float)interpolant divisor:(float)divisor;
+ (float) repeatValue:(float)value frequency:(float)frequency;
+ (float) stepWithValue:(float)value edge:(float)edge;
+ (float) pulseWithValue:(float)value leadingEdge:(float)leadingEdge trailingEdge:(float)trailingEdge;
+ (float) sign:(float)f;

@end
