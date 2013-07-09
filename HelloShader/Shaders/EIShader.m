//
// Created by turner on 7/9/13.
// Copyright (c) 2013 Elastic Image Software. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "EIShader.h"


@implementation EIShader

@synthesize programHandle = _programHandle;
@synthesize shaderPrefix = _shaderPrefix;

- (void)dealloc {

    self.shaderPrefix = nil;
    glDeleteProgram(_programHandle);

    [super dealloc];
}

- (id)initWithShaderPrefix:(NSString *)shaderPrefix programHandle:(GLuint)programHandle {
    
    self = [super init];
    if (nil != self) {
        self.shaderPrefix = shaderPrefix;
        self.programHandle = programHandle;
    }
    return self;

}

@end