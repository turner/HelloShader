//
//  FBOTextureTarget.h
//  EISElasticImage
//
//  Created by Douglass Turner on 1/8/11.
//  Copyright 2011 Elastic Image Software LLC. All rights reserved.
//

#import "FBOTextureTarget.h"
#import "EIRenderer.h"
#import "EITextureOldSchool.h"
#import "EIGLUtils.h"
#import "EIQuad.h"

@implementation FBOTextureTarget

@synthesize fboTexture = _fboTexture;
@synthesize fbo = _fbo;

- (void)dealloc {

    self.fboTexture = nil;

    if (_fbo) {
        glDeleteFramebuffers(1, &_fbo);
        _fbo = 0;
    }

    [super dealloc];
}



//self.texture = ...;
//[self.renderer.texturePackages setObject:self.texture forKey:self.fboTextureTargetName];



- (id)initWithFBOTexture:(EITextureOldSchool *)fboTexture {

    self = [super init];

    if (nil != self) {

        self.fboTexture = fboTexture;

        glGenFramebuffers(1, &_fbo);
        glBindFramebuffer(GL_FRAMEBUFFER, self.fbo);

        // Attach fboTexture to FBO
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, self.fboTexture.name, 0);

        [EIGLUtils FBOStatus];

    }
    
    return self;
}

@end