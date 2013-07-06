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
- (id)initWithTextureTarget:(EITexture *)textureTarget;
@property (nonatomic, retain) EITexture *textureTarget;
@property(nonatomic) GLuint fbo;
@end