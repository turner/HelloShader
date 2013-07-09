///
//  FBOTextureTarget.h
//  EISElasticImage
//
//  Created by Douglass Turner on 1/8/11.
//  Copyright 2011 Elastic Image Software LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GLRenderer;
@class EITextureOldSchool;

@interface FBOTextureTarget : NSObject
- (id)initWithFBOTexture:(EITextureOldSchool *)fboTexture;
@property (nonatomic, retain) EITextureOldSchool *fboTexture;
@property(nonatomic) GLuint fbo;
@end