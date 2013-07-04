//
//  GLRenderer.h
//  HelloiPhoneiPodTouchPanorama
//
//  Created by turner on 2/25/10.
//  Copyright Douglass Turner Consulting 2010. All rights reserved.
//

#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@class EISRendererHelper;
@class CAEAGLLayer;

@interface GLRenderer : NSObject

@property (nonatomic, retain) EISRendererHelper *rendererHelper;
@property (nonatomic, retain) NSMutableDictionary *texturePackages;

- (void) render;
- (BOOL) resizeFromLayer:(CAEAGLLayer *)layer;
- (void) setupGLView:(CGSize)size;

@end

