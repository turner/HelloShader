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
#import "EISRendererHelper.h"
#import "EISGLUtils.h"

@interface FBOTextureRenderer ()
@property(nonatomic, retain) EIQuad *renderSurface;
@property(nonatomic, retain) EISRendererHelper *rendererHelper;
@end

@implementation FBOTextureRenderer

@synthesize shaderProgram = _shaderProgram;
@synthesize fboTextureRenderTarget = _fboTextureRenderTarget;
@synthesize renderSurface = _renderSurface;
@synthesize rendererHelper = _rendererHelper;
@synthesize uniforms = _uniforms;

- (void)dealloc {

    free(self.uniforms);

    self.renderSurface = nil;
    self.fboTextureRenderTarget = nil;
    self.rendererHelper = nil;

    if (_shaderProgram) {
        glDeleteProgram(_shaderProgram);
        _shaderProgram = 0;
    }

    [super dealloc];
}

- (id)initWithRenderSurface:(EIQuad *)renderSurface fboTextureRenderTarget:(FBOTextureRenderTarget *)fboTextureRenderTarget rendererHelper:(EISRendererHelper *)rendererHelper {

    self = [super init];

    if (nil != self) {

        self.uniforms = (GLint *)malloc(UniformCount * sizeof(NSUInteger));

        self.renderSurface = renderSurface;

        self.fboTextureRenderTarget = fboTextureRenderTarget;

        self.rendererHelper = rendererHelper;
        [self.rendererHelper setupProjectionViewModelTransformWithRenderSurfaceHalfSize:self.renderSurface.halfSize];
    }

    return self;
}

#pragma mark -
#pragma mark EISRenderer - render

- (void) render {

    glBindFramebuffer(GL_FRAMEBUFFER, self.fboTextureRenderTarget.fbo);
    glViewport(0, 0, (GLsizei)(2 * self.renderSurface.halfSize.width), (GLsizei)(2 * self.renderSurface.halfSize.height));

    glClearColor(0.0f, 0.0f, .0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);

    glEnable(GL_TEXTURE_2D);
   	glEnable(GL_DEPTH_TEST);
   	glFrontFace(GL_CCW);

    // Pre-multiplied Alpha. This is what is produced by Photoshop when a mask is applied.
   	glEnable (GL_BLEND);
   	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);




    // Bind shaderProgram program
    glUseProgram(_shaderProgram);

    int mat = [[[[self.shaderProgram objectForKey:@"uniforms"] objectForKey:@"projectionViewModelMatrix"] objectForKey:@"glslSampler"] intValue];
    glUniformMatrix4fv(mat, 1, NO, [self.rendererHelper projectionViewModelTransform]);

    GLuint xyz = (GLuint)[[[self.shaderProgram objectForKey:@"vertexAttributes"] objectForKey:@"vertexXYZ"] intValue];
    glVertexAttribPointer(xyz, 3, GL_FLOAT, 0, 0, self.renderSurface.vertices);
    glEnableVertexAttribArray(xyz);

    GLuint st = (GLuint)[[[self.shaderProgram objectForKey:@"vertexAttributes"] objectForKey:@"vertexST"] intValue];
    glVertexAttribPointer(st, 2, GL_FLOAT, 0, 0, [EISRendererHelper verticesST]);
    glEnableVertexAttribArray(st);

    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

    // Unbind FBO
    glBindFramebuffer(GL_FRAMEBUFFER, 0);

}

@end
