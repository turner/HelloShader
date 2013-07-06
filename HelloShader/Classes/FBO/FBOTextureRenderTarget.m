//
//  FBOTextureRenderTarget.h
//  EISElasticImage
//
//  Created by Douglass Turner on 1/8/11.
//  Copyright 2011 Elastic Image Software LLC. All rights reserved.
//

#import "FBOTextureRenderTarget.h"
#import "GLRenderer.h"
#import "EITexture.h"
#import "EISGLHelpful.h"

@implementation FBOTextureRenderTarget {
    GLuint _fbo;
}

@synthesize texture;
@synthesize renderer;
@synthesize fboTextureTargetName;
@synthesize fbo = _fbo;

- (void)dealloc {

    [self.renderer.texturePackages removeObjectForKey:self.fboTextureTargetName];
    self.texture = nil;

    self.fboTextureTargetName = nil;
    self.renderer = nil;

    if (_fbo) {

        glDeleteFramebuffers(1, &_fbo);
        _fbo = 0;
    }

    [super dealloc];
}

- (id)initWithRenderer:(GLRenderer *)aRender renderSurfaceSize:(CGSize)aRenderSurfaceSize fboTextureTargetName:(NSString *)aFBOTextureTargetName {

    self = [super init];

    if (nil != self) {

        self.renderer = aRender;

        self.texture = [[[EITexture alloc] initFBORenderTextureRGBA8Width:(NSUInteger)aRenderSurfaceSize.width height:(NSUInteger)aRenderSurfaceSize.height] autorelease];

        self.fboTextureTargetName = aFBOTextureTargetName;

        glGenFramebuffers(1, &_fbo);
        glBindFramebuffer(GL_FRAMEBUFFER, _fbo);

        // Attach texture to FBO
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, self.texture.name, 0);

        [EISGLHelpful FBOStatus];


        [self.renderer.texturePackages setObject:self.texture forKey:self.fboTextureTargetName];

    }

    return self;
}

@end