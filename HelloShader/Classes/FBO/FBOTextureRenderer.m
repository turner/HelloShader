//
//  FBOTextureRenderer.m
//  EISElasticImage
//
//  Created by Douglass Turner on 1/31/11.
//  Copyright 2011 Elastic Image Software LLC. All rights reserved.
//

#import "FBOTextureRenderer.h"
#import "FBOTextureRenderTarget.h"
#import "EIQuad.h"
#import "GLRenderer.h"

@interface FBOTextureRenderer ()
@property(nonatomic, retain) EIQuad *quad;
@property(nonatomic, retain) EISRendererHelper *rendererHelper;
@property(nonatomic, retain) GLRenderer *renderer;
@property(nonatomic, assign) CGSize renderSurfaceSize;

@end

@implementation FBOTextureRenderer

@synthesize rendererHelper;
@synthesize shader;
@synthesize fboTextureRenderTarget;
@synthesize renderer;
@synthesize quad;
@synthesize renderSurfaceSize = _renderSurfaceSize;

- (void)dealloc {

    self.quad = nil;
    self.rendererHelper = nil;
    self.renderer = nil;
    self.shader = nil;
    self.fboTextureRenderTarget = nil;

    [super dealloc];
}

- (id)initWithRenderer:(GLRenderer *)aRenderer renderSurfaceSize:(CGSize)aRenderSurfaceSize fboTextureTargetName:(NSString *)aFBOTextureTargetName {

    self = [super init];

    if (nil != self) {

        self.renderer = aRenderer;
        self.fboTextureRenderTarget = [[[FBOTextureRenderTarget alloc] initWithRenderer:self.renderer renderSurfaceSize:aRenderSurfaceSize fboTextureTargetName:aFBOTextureTargetName] autorelease];

        self.quad = [[[EIQuad alloc] initWithHalfSize:CGSizeMake(aRenderSurfaceSize.width / 2.0, aRenderSurfaceSize.height / 2.0)] autorelease];

        // Create viewport and orthographic camera aligned to quad
        self.rendererHelper = [[[EISRendererHelper alloc] init] autorelease];

        self.renderSurfaceSize = CGSizeMake(aRenderSurfaceSize.width, aRenderSurfaceSize.height);

        [self.rendererHelper orthographicProjectionLeft:-(self.renderSurfaceSize.width /2.0)
                                                  right: (self.renderSurfaceSize.width /2.0)
                                                    top: (self.renderSurfaceSize.height/2.0)
                                                 bottom:-(self.renderSurfaceSize.height/2.0)
                                                   near:0.100
                                                    far:100.0];

        // P * V -> PV
        EISMatrix4x4Multiply([self.rendererHelper projection], [self.rendererHelper viewTransform], [self.rendererHelper projectionViewTransform]);

        // PV * M -> PVM
        EISMatrix4x4Multiply([self.rendererHelper projectionViewTransform], [self.rendererHelper modelTransform], [self.rendererHelper projectionViewModelTransform]);
    }

    return self;
}

#pragma mark -
#pragma mark EISRenderer - render

- (void) render {

    glBindFramebuffer(GL_FRAMEBUFFER, self.fboTextureRenderTarget.fbo);

    glEnable(GL_TEXTURE_2D);
   	glEnable(GL_DEPTH_TEST);
   	glFrontFace(GL_CCW);

    // Pre-multiplied Alpha. This is what is produced by Photoshop when a mask is applied.
   	glEnable (GL_BLEND);
   	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    glViewport(0, 0, (GLsizei)self.renderSurfaceSize.width, (GLsizei)self.renderSurfaceSize.height);

    glClearColor(0.0f, 0.0f, .0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);


    // Bind shader program
    glUseProgram((GLuint)[[self.shader objectForKey:@"program"] unsignedIntValue]);

    int mat = [[[[self.shader objectForKey:@"uniforms"] objectForKey:@"projectionViewModelMatrix"] objectForKey:@"location"] intValue];
    glUniformMatrix4fv(mat, 1, NO, [self.rendererHelper projectionViewModelTransform]);

    GLuint xyz = (GLuint)[[[self.shader objectForKey:@"vertexAttributes"] objectForKey:@"vertexXYZ"] intValue];
    glVertexAttribPointer(xyz, 3, GL_FLOAT, 0, 0, self.quad.vertices);
    glEnableVertexAttribArray(xyz);

    GLuint st = (GLuint)[[[self.shader objectForKey:@"vertexAttributes"] objectForKey:@"vertexST"] intValue];
    glVertexAttribPointer(st, 2, GL_FLOAT, 0, 0, [EISRendererHelper verticesST]);
    glEnableVertexAttribArray(st);

    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

    // Unbind FBO
    glBindFramebuffer(GL_FRAMEBUFFER, 0);

}

@end
