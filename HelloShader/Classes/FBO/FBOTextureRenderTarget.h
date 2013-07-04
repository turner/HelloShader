///
//  FBOTextureRenderTarget.h
//  EISElasticImage
//
//  Created by Douglass Turner on 1/8/11.
//  Copyright 2011 Elastic Image Software LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GLRenderer;
@class EITexture;

@interface FBOTextureRenderTarget : NSObject

- (id)initWithRenderer:(GLRenderer *)aRender renderSurfaceSize:(CGSize)aRenderSurfaceSize fboTextureTargetName:(NSString *)aFBOTextureTargetName;

@property (nonatomic, retain) EITexture *texture;
@property (nonatomic, retain) GLRenderer *renderer;
@property (nonatomic,   copy) NSString *fboTextureTargetName;
@property (nonatomic        ) GLuint fbo;
@property(nonatomic, retain) NSMutableDictionary *textureTarget;
@end