//
//  GLHelpful.m
//  BeautifulPanoramas
//
//  Created by Douglass Turner on 12/4/10.
//  Copyright 2010 Elastic Image Software LLC. All rights reserved.
//

#import "EIGLUtils.h"
#import "Logging.h"

@implementation EIGLUtils

+ (void)clearErrors {

    while( glGetError() != GL_NO_ERROR ) { /* do nothing */; }
}

+ (void) FBOStatus {

    GLenum status = (GLenum)glCheckFramebufferStatus(GL_FRAMEBUFFER);

    switch(status) {

        default:
        case GL_FRAMEBUFFER_COMPLETE:
            ALog(@"FBO complete");
            break;

        case GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT:
			ALog(@"FBO incomplete - attachment");
            break;

        case GL_FRAMEBUFFER_UNSUPPORTED:
            ALog(@"FBO unsupported");
            break;

        case GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT:
            ALog(@"FBO incomplete - missing attachment");
            break;

    }

}

+ (BOOL)error {

    switch( glGetError() ) {

        default:
        case GL_NO_ERROR:
            return YES;

        case GL_INVALID_ENUM:
            ALog(@"GL_INVALID_ENUM");
            return NO;

        case GL_INVALID_VALUE:
            ALog(@"GL_INVALID_VALUE");
            return NO;

        case GL_INVALID_OPERATION:
            ALog(@"GL_INVALID_OPERATION");
            return NO;

        case GL_STACK_OVERFLOW:
            ALog(@"GL_STACK_OVERFLOW");
            return NO;

        case GL_STACK_UNDERFLOW:
            ALog(@"GL_STACK_UNDERFLOW");
            return NO;

        case GL_OUT_OF_MEMORY:
            ALog(@"GL_OUT_OF_MEMORY");
            return NO;

    }

}

+ (NSString *)errorString {

    switch( glGetError() ) {

        default:
        case GL_NO_ERROR:
            return @"";

        case GL_INVALID_ENUM:
            return @"Invalid enum";

        case GL_INVALID_VALUE:
            return @"Invalid value";

        case GL_INVALID_OPERATION:
            return @"Invalid operation";

        case GL_STACK_OVERFLOW:
            return @"Stack overflow";

        case GL_STACK_UNDERFLOW:
            return @"Stack underflow";

        case GL_OUT_OF_MEMORY:
            return @"Out of memory";

    }

}

+ (void)checkGLError {

    // do stuff
}

@end
