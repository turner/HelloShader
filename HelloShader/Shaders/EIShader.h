//
// Created by turner on 7/8/13.
// Copyright (c) 2013 Elastic Image Software. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import <Foundation/Foundation.h>

@class EITextureOldSchool;

typedef void (^EIShaderTextureShaderSetup)(GLuint shaderProgram, EITextureOldSchool *hero);
typedef void (^EIShaderTexturePairShaderSetup)(GLuint shaderProgram, EITextureOldSchool *matte, EITextureOldSchool *hero);
typedef void (^EIShaderGaussianBlurShaderSetup)(GLuint shaderProgram, EITextureOldSchool *hero);

@interface EIShader : NSObject
@property (nonatomic, retain) NSMutableDictionary *shaderSetupBlocks;

+ (EIShader *)sharedEIShader;
@end