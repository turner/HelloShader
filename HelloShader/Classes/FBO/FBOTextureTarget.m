//
//  FBOTextureTarget.h
//  EISElasticImage
//
//  Created by Douglass Turner on 1/8/11.
//  Copyright 2011 Elastic Image Software LLC. All rights reserved.
//

#import "FBOTextureTarget.h"
#import "GLRenderer.h"
#import "EITextureOldSchool.h"
#import "EISGLUtils.h"
#import "EIQuad.h"

@implementation FBOTextureTarget

@synthesize textureTarget = _textureTarget;
@synthesize fbo = _fbo;

- (void)dealloc {

    self.textureTarget = nil;

    if (_fbo) {
        glDeleteFramebuffers(1, &_fbo);
        _fbo = 0;
    }

    [super dealloc];
}



//self.texture = ...;
//[self.renderer.texturePackages setObject:self.texture forKey:self.fboTextureTargetName];



- (id)initWithTextureTarget:(EITextureOldSchool *)textureTarget {

    self = [super init];

    if (nil != self) {

        self.textureTarget = textureTarget;

        glGenFramebuffers(1, &_fbo);
        glBindFramebuffer(GL_FRAMEBUFFER, self.fbo);

        // Attach textureTarget to FBO
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, self.textureTarget.name, 0);

        [EISGLUtils FBOStatus];

    }
    
    return self;
}

@end