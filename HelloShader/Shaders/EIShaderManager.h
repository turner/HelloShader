//
// Created by turner on 7/8/13.
// Copyright (c) 2013 Elastic Image Software. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import <Foundation/Foundation.h>

@class EITextureOldSchool;

typedef void (^TextureShaderSetup)(GLuint shaderProgram, EITextureOldSchool *hero);
typedef void (^TexturePairShaderSetup)(GLuint shaderProgram, EITextureOldSchool *matte, EITextureOldSchool *hero);
typedef void (^GaussianBlurShaderSetup)(GLuint shaderProgram, EITextureOldSchool *hero);

@interface EIShaderManager : NSObject
@property (nonatomic, retain) NSMutableDictionary *shaderSetupBlocks;

+ (EIShaderManager *)sharedShaderManager;

@end