//
//  FBOTextureTargetRenderer.m
//  EISElasticImage
//
//  Created by Douglass Turner on 1/31/11.
//  Copyright 2011 Elastic Image Software LLC. All rights reserved.
//

#import "FBOTextureTargetRenderer.h"
#import "FBOTextureTarget.h"
#import "EIQuad.h"
#import "EIRenderer.h"
#import "EIRendererHelper.h"
#import "EIGLUtils.h"
#import "EITextureOldSchool.h"
#import "EIShaderManager.h"
#import "EIShader.h"

@interface FBOTextureTargetRenderer ()
@property(nonatomic, retain) EIQuad *renderSurface;
@property(nonatomic, retain) EIRendererHelper *rendererHelper;
@property(nonatomic) GLint *uniforms;
@end

@implementation FBOTextureTargetRenderer

@synthesize fboTextureTarget = _fboTextureTarget;
@synthesize renderSurface = _renderSurface;
@synthesize rendererHelper = _rendererHelper;
@synthesize uniforms = _uniforms;
@synthesize shaderProgram = _shaderProgram;

- (void)dealloc {

    free(self.uniforms);

    self.renderSurface = nil;
    self.fboTextureTarget = nil;
    self.rendererHelper = nil;
    self.shaderProgram = nil;

    [super dealloc];
}

- (id)initWithRenderSurface:(EIQuad *)renderSurface fboTextureTarget:(FBOTextureTarget *)fboTextureTarget rendererHelper:(EIRendererHelper *)rendererHelper {

    self = [super init];

    if (nil != self) {

        self.uniforms = (GLint *)malloc(UniformCount * sizeof(NSUInteger));

        self.renderSurface = renderSurface;

        self.fboTextureTarget = fboTextureTarget;

        self.rendererHelper = rendererHelper;

        [self.rendererHelper setupProjectionViewModelTransformWithRenderSurfaceHalfSize:self.renderSurface.halfSize];

        self.shaderProgram = [EIShaderManager shaderProgramWithShaderPrefix:@"EISTexturePairShader"];
        glUseProgram(self.shaderProgram.programHandle);

        // Get shaderProgram uniform pointers
        self.uniforms[Uniform_ProjectionViewModel] = glGetUniformLocation(self.shaderProgram.programHandle, "projectionViewModelMatrix");
        self.uniforms[Uniform_ViewModelMatrix    ] = glGetUniformLocation(self.shaderProgram.programHandle, "viewModelMatrix");
        self.uniforms[Uniform_ModelMatrix        ] = glGetUniformLocation(self.shaderProgram.programHandle, "modelMatrix");
        self.uniforms[Uniform_SurfaceNormalMatrix] = glGetUniformLocation(self.shaderProgram.programHandle, "normalMatrix");

    }

    return self;
}

#pragma mark -
#pragma mark EISRenderer - render

- (void) render {

    // clear all current texture bindings
    glBindTexture(GL_TEXTURE_2D, 0);

    glBindFramebuffer(GL_FRAMEBUFFER, self.fboTextureTarget.fbo);
    glViewport(0, 0, self.fboTextureTarget.fboTexture.width, self.fboTextureTarget.fboTexture.height);

    glClearColor(0.0f, 0.0f, .0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);

    glEnable(GL_TEXTURE_2D);
   	glEnable(GL_DEPTH_TEST);
   	glFrontFace(GL_CCW);

    // Pre-multiplied Alpha. This is what is produced by Photoshop when a mask is applied.
   	glEnable (GL_BLEND);
   	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    TexturePairShaderSetup texturePairShaderSetup = [[EIShaderManager sharedShaderManager].shaderSetupBlocks objectForKey:@"texturePairShaderSetup"];
    texturePairShaderSetup(self.shaderProgram.programHandle, [self.rendererHelper.renderables objectForKey:@"matte"], [self.rendererHelper.renderables objectForKey:@"hero"]);

    glUseProgram(self.shaderProgram.programHandle);

    // M - World space - this defaults to the identify matrix
    glUniformMatrix4fv(self.uniforms[Uniform_ModelMatrix], 1, NO, [self.rendererHelper modelTransform]);

    // The surface normal transform is the inverse of M
    glUniformMatrix4fv(self.uniforms[Uniform_SurfaceNormalMatrix], 1, NO, [self.rendererHelper surfaceNormalTransform]);

    // V * M - Eye space
    EISMatrix4x4Multiply([self.rendererHelper viewTransform], [self.rendererHelper modelTransform], [self.rendererHelper viewModelTransform]);
    glUniformMatrix4fv(self.uniforms[Uniform_ViewModelMatrix], 1, NO, [self.rendererHelper viewModelTransform]);

    // P * V * M - Projection space
    EISMatrix4x4Multiply([self.rendererHelper projection], [self.rendererHelper viewModelTransform], [self.rendererHelper projectionViewModelTransform]);
    glUniformMatrix4fv(self.uniforms[Uniform_ProjectionViewModel], 1, NO, [self.rendererHelper projectionViewModelTransform]);

    glEnableVertexAttribArray(Attribute_VertexXYZ);
    glEnableVertexAttribArray(Attribute_VertexST);

    glVertexAttribPointer(Attribute_VertexXYZ, 3, GL_FLOAT, 0, 0, self.renderSurface.vertices);
    glVertexAttribPointer(Attribute_VertexST,  2, GL_FLOAT, 0, 0, [EIRendererHelper verticesST]);

    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

    // Unbind FBO
    glBindFramebuffer(GL_FRAMEBUFFER, 0);

}

@end
