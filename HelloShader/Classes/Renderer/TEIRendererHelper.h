//
//  TEIRendererHelper.h
//  HelloiPhoneiPodTouchPanorama
//
//  Created by turner on 3/4/10.
//  Copyright 2010 Douglass Turner Consulting. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

#import "ConstantsAndMacros.h"
#import "VectorMatrix.h"

@interface TEIRendererHelper : NSObject {

	M3DMatrix44f	m_projectionViewModelTransform;
	M3DMatrix44f	m_viewModelTransform;

	M3DMatrix44f	m_projection;
	M3DMatrix44f	m_modelTransform;
	M3DMatrix44f	m_viewTransform;

	M3DMatrix44f	m_cameraTransform;
	M3DMatrix44f	m_surfaceNormalTransform;
	
	NSMutableDictionary	*m_renderables;

}

- (float *) projectionViewModelTransform; 
- (void) setProjectionViewModelTransform:(M3DMatrix44f)input; 

- (float *) viewModelTransform; 
- (void) setViewModelTransform:(M3DMatrix44f)input; 

- (float *) projection; 
- (void) setProjection:(M3DMatrix44f)input; 

- (float *) modelTransform; 
- (void) setModelTransform:(M3DMatrix44f)input; 

- (float *) viewTransform; 

- (float *) cameraTransform; 

- (float *) surfaceNormalTransform; 

@property(nonatomic,retain)NSMutableDictionary *renderables;

- (void)placeCameraAtLocation:(M3DVector3f)location target:(M3DVector3f)target up:(M3DVector3f)up;

- (void)perspectiveProjectionWithFieldOfViewInDegreesY:(GLfloat)fieldOfViewInDegreesY 
							aspectRatioWidthOverHeight:(GLfloat)aspectRatioWidthOverHeight 
												  near:(GLfloat)near 
												   far:(GLfloat)far;

@end
