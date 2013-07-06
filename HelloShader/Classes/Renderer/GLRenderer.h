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
@class EIQuad;

@interface GLRenderer : NSObject
- (id)initWithContext:(EAGLContext *)context renderHelper:(EISRendererHelper *)aRenderHelper;
@property (nonatomic, retain) EISRendererHelper *rendererHelper;
@property (nonatomic, retain) NSMutableDictionary *texturePackages;

- (void) render;
- (BOOL) resizeFromLayer:(CAEAGLLayer *)layer;
- (BOOL)loadShaderWithPrefix:(NSString *)shaderPrefix;
@end

