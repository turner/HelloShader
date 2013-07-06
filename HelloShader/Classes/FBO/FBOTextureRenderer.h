//
//  FBOTextureRenderer.h
//  EISElasticImage
//
//  Created by Douglass Turner on 1/31/11.
//  Copyright 2011 Elastic Image Software LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FBOTextureRenderTarget;
@class GLRenderer;
@class EIQuad;
@class EISRendererHelper;

@interface FBOTextureRenderer : NSObject
- (id)initWithRenderSurface:(EIQuad *)renderSurface fboTextureRenderTarget:(FBOTextureRenderTarget *)fboTextureRenderTarget rendererHelper:(EISRendererHelper *)rendererHelper;

@property(nonatomic, retain) FBOTextureRenderTarget *fboTextureRenderTarget;
@property(nonatomic) GLuint shaderProgram;
- (void)render;
@end
