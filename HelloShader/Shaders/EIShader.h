//
// Created by turner on 7/9/13.
// Copyright (c) 2013 Elastic Image Software. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

@interface EIShader : NSObject
- (id)initWithProgramHandle:(GLuint)programHandle;
@property(nonatomic) GLuint programHandle;
@end