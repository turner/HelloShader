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
#import "EITextureOldSchool.h"
#import "EIShaderManager.h"
#import "EIShader.h"

@interface FBOTextureRenderer ()
@property(nonatomic, retain) EIQuad *renderSurface;
@property(nonatomic, retain) EISRendererHelper *rendererHelper;
@end

@implementation FBOTextureRenderer

@synthesize fboTextureRenderTarget = _fboTextureRenderTarget;
@synthesize renderSurface = _renderSurface;
@synthesize rendererHelper = _rendererHelper;
@synthesize uniforms = _uniforms;
@synthesize shaderProgram = _shaderProgram;

- (void)dealloc {

    free(self.uniforms);

    self.renderSurface = nil;
    self.fboTextureRenderTarget = nil;
    self.rendererHelper = nil;
    self.shaderProgram = nil;

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

        [self.rendererHelper.renderables setObject:self.fboTextureRenderTarget.textureTarget forKey:kFBOTextureRenderTargetTextureName];


        // Configure fbo shader - specifically for texture pair shader
        NSString *shaderPrefix = @"EISTexturePairShader";
        self.shaderProgram = [GLRenderer shaderProgramWithShaderPrefix:shaderPrefix];

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

    glBindFramebuffer(GL_FRAMEBUFFER, self.fboTextureRenderTarget.fbo);
    glViewport(0, 0, self.fboTextureRenderTarget.textureTarget.width, self.fboTextureRenderTarget.textureTarget.height);

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
    glVertexAttribPointer(Attribute_VertexST,  2, GL_FLOAT, 0, 0, [EISRendererHelper verticesST]);

    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

    // Unbind FBO
    glBindFramebuffer(GL_FRAMEBUFFER, 0);

}

- (void)pingPongWithSeedShader:(GLuint)seedShader pingShader:(GLuint)pingShader pongShader:(GLuint)pongShader passes:(NSUInteger)passes {

//    //
//    self.shaderProgram = seedShader;
//
//
//
//
//
//    EITexture *texture = [[self.texturePackages objectForKey:textureName] objectForKey:@"texture"];
//
//    self.fboPingRenderer = [[[FBOTextureRenderer alloc] initWith ...] autorelease];
//    self.fboPingRenderer.shader = EISGaussianBlurEastWest;
//
//
//    self.fboPongRenderer = [[[FBOTextureRenderer alloc] initWith ...] autorelease];
//    self.fboPongRenderer.shader = EISGaussianBlurNorthSouth;
//
//
//
//
//    // Render a series of passes. Blurring is achieved on two passes - horizontal then vertical. Over and over again.
//    NSString *pingTextureName = self.fboPingRenderer.fboTextureRenderTarget.fboTextureTargetName;
//    NSString *pongTextureName = self.fboPingRenderer.fboTextureRenderTarget.fboTextureTargetName;
//
//    NSArray *passes = [NSArray arrayWithObjects:
//
//                    // FBO 0 input                             FBO 1 input
//                    [NSArray arrayWithObjects:@"hero",         pingTextureName, nil],
//
//                    // FBO 0 input                             FBO 1 input
//                    [NSArray arrayWithObjects:pongTextureName, pingTextureName, nil],
//
//                    // FBO 0 input                             FBO 1 input
//                    [NSArray arrayWithObjects:pongTextureName, pingTextureName, nil],
//
//                    // FBO 0 input                             FBO 1 input
//                    [NSArray arrayWithObjects:pongTextureName, pingTextureName, nil],
//
//            nil];
//
//    for (NSArray *pass in passes) {
//
//        glUseProgram((GLuint)[[self.fboPingRenderer.shader objectForKey:@"program"] unsignedIntValue]);
//        [self.fboPingRenderer.shader setTextureUniformName:@"hero" withTextureName:[pass objectAtIndex:0] renderer:self];
//        [self.fboPingRenderer render];
//
//        glUseProgram((GLuint)[[self.fboPongRenderer.shader objectForKey:@"program"] unsignedIntValue]);
//        [self.fboPongRenderer.shader setTextureUniformName:@"hero" withTextureName:[pass objectAtIndex:1] renderer:self];
//        [self.fboPongRenderer render];
//    }

}

@end
