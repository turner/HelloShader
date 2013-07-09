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
@class FBOTextureRenderer;
@class EIShader;

@interface GLRenderer : NSObject

- (id)initWithContext:(EAGLContext *)context renderHelper:(EISRendererHelper *)aRenderHelper;

@property (nonatomic, retain) EISRendererHelper *rendererHelper;
@property (nonatomic, retain) NSMutableDictionary *texturePackages;
@property (nonatomic, retain) FBOTextureRenderer *fboTextureRenderer;
@property (nonatomic, retain) EIShader *shaderProgram;

- (BOOL) resizeFromLayer:(CAEAGLLayer *)layer;
- (void) render;
+ (EIShader *)shaderProgramWithShaderPrefix:(NSString *)shaderPrefix;
@end

