//
// Created by turner on 7/9/13.
// Copyright (c) 2013 Elastic Image Software. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

@interface EIShader : NSObject
- (id)initWithShaderPrefix:(NSString *)shaderPrefix programHandle:(GLuint)programHandle;
@property(nonatomic) GLuint programHandle;
@property(nonatomic, copy) NSString *shaderPrefix;
@end