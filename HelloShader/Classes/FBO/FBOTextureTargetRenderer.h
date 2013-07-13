//
//  FBOTextureTargetRenderer.h
//  EISElasticImage
//
//  Created by Douglass Turner on 1/31/11.
//  Copyright 2011 Elastic Image Software LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FBOTextureTarget;
@class EIRendererHelper;
@class EIShader;
@class EIQuad;

@interface FBOTextureTargetRenderer : NSObject
- (id)initWithRenderSurface:(EIQuad *)renderSurface fboTextureTarget:(FBOTextureTarget *)fboTextureTarget rendererHelper:(EIRendererHelper *)rendererHelper;
@property(nonatomic, retain) FBOTextureTarget *fboTextureTarget;
@property(nonatomic, retain) EIShader *shaderProgram;
- (void)render;
@end
