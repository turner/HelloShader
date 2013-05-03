//
//  GLRenderer.h
//  HelloiPhoneiPodTouchPanorama
//
//  Created by turner on 2/25/10.
//  Copyright Douglass Turner Consulting 2010. All rights reserved.
//

#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@class TEIRendererHelper;
@class CAEAGLLayer;

@interface GLRenderer : NSObject {
	
@private
	TEIRendererHelper *m_rendererHelper;

	EAGLContext *m_context;
	
	GLint m_backingWidth;
	GLint m_backingHeight;
	
	GLuint m_framebuffer;
	GLuint m_colorbuffer;
	GLuint m_depthbuffer;
	
	GLuint m_program;
}

@property (nonatomic, retain) TEIRendererHelper *rendererHelper;

- (void) render;
- (BOOL) resizeFromLayer:(CAEAGLLayer *)layer;
- (void) setupGLView:(CGSize)size;

@end
