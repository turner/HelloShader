//
//  EIRenderer.h
//  HelloiPhoneiPodTouchPanorama
//
//  Created by turner on 2/25/10.
//  Copyright Douglass Turner Consulting 2010. All rights reserved.
//

#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@class EIRendererHelper;
@class CAEAGLLayer;
@class EIQuad;
@class FBOTextureTargetRenderer;
@class EIShader;

@interface EIRenderer : NSObject

- (id)initWithContext:(EAGLContext *)context renderHelper:(EIRendererHelper *)aRenderHelper;

@property (nonatomic, retain) EIRendererHelper *rendererHelper;
@property (nonatomic, retain) NSMutableDictionary *texturePackages;
@property (nonatomic, retain) FBOTextureTargetRenderer *fboTextureTargetRenderer;
@property (nonatomic, retain) EIShader *shaderProgram;

- (BOOL) resizeFromLayer:(CAEAGLLayer *)layer;
- (void) render;
@end

