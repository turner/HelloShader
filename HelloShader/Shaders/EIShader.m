//
// Created by turner on 7/9/13.
// Copyright (c) 2013 Elastic Image Software. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "EIShader.h"


@implementation EIShader

@synthesize programHandle = _programHandle;

- (void)dealloc {

    glDeleteProgram(_programHandle);

    [super dealloc];
}

- (id)initWithProgramHandle:(GLuint)programHandle {
    
    self = [super init];
    if (nil != self) {

        self.programHandle = programHandle;
    }
    return self;

}

@end