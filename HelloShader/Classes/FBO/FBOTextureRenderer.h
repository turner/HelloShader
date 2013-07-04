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

@interface FBOTextureRenderer : NSObject
- (id)initWithRenderer:(GLRenderer *)aRenderer renderSurfaceSize:(CGSize)aRenderSurfaceSize fboTextureTargetName:(NSString *)aFBOTextureTargetName;
@property(nonatomic, retain) FBOTextureRenderTarget *fboTextureRenderTarget;
@property(nonatomic, retain) NSMutableDictionary *shader;
- (void)render;
@end
