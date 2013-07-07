///
//  FBOTextureRenderTarget.h
//  EISElasticImage
//
//  Created by Douglass Turner on 1/8/11.
//  Copyright 2011 Elastic Image Software LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kFBOTextureRenderTargetTextureName;

@class GLRenderer;
@class EITextureOldSchool;

@interface FBOTextureRenderTarget : NSObject
- (id)initWithTextureTarget:(EITextureOldSchool *)textureTarget;
@property (nonatomic, retain) EITextureOldSchool *textureTarget;
@property(nonatomic) GLuint fbo;
@end