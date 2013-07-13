//
//  EIRenderer.m
//  HelloShader
//
//  Created by turner on 2/25/10.
//  Copyright Douglass Turner Consulting 2010. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "EIRenderer.h"
#import "EIRendererHelper.h"
#import "EITextureOldSchool.h"
#import "Logging.h"
#import "EIQuad.h"
#import "FBOTextureTarget.h"
#import "FBOTextureTargetRenderer.h"
#import "EIGLUtils.h"
#import "EIShaderManager.h"
#import "EIShader.h"

@interface EIRenderer ()
@property(nonatomic, retain) EIQuad *renderSurface;
@property(nonatomic) GLint *uniforms;
- (void)setupGLWithFramebufferSize:(CGSize)framebufferSize;
@end

@implementation EIRenderer {

    EAGLContext *_context;
    GLint _backingWidth;
    GLint _backingHeight;
    GLuint _framebuffer;
    GLuint _colorbuffer;
    GLuint _depthbuffer;
}

@synthesize uniforms = _uniforms;
@synthesize texturePackages = _texturePackages;
@synthesize rendererHelper = _rendererHelper;
@synthesize renderSurface = _renderSurface;
@synthesize shaderProgram = _shaderProgram;
@synthesize fboTextureTargetRenderer;

- (void) dealloc {

    free(self.uniforms);

    if (_framebuffer) {
		glDeleteFramebuffers(1, &_framebuffer);
		_framebuffer = 0;
	}
	
	if (_colorbuffer) {
		glDeleteRenderbuffers(1, &_colorbuffer);
		_colorbuffer = 0;
	}
	
	if (_depthbuffer) {
		glDeleteRenderbuffers(1, &_depthbuffer);
		_depthbuffer = 0;
	}

	if ([EAGLContext currentContext] == _context) [EAGLContext setCurrentContext:nil];
	[_context release]; _context = nil;

    self.texturePackages = nil;
    self.rendererHelper = nil;
    self.renderSurface = nil;
    self.fboTextureTargetRenderer = nil;
    self.shaderProgram = nil;

    [super dealloc];
}

-(id)initWithContext:(EAGLContext *)context renderHelper:(EIRendererHelper *)aRenderHelper {

    self = [super init];

    if (nil != self) {

        self.uniforms = (GLint *)malloc(UniformCount * sizeof(NSUInteger));

        _context = context;

        if (!_context) {

            return nil;
        }

        if (NO == [EAGLContext setCurrentContext:_context]) {
            return nil;
        }

        _backingWidth = -1;
        _backingHeight = -1;

        self.rendererHelper = aRenderHelper;
    }

    return self;
}

-(NSMutableDictionary *)texturePackages {

    if (nil == _texturePackages) {
        self.texturePackages = [NSMutableDictionary dictionary];
    }

    return _texturePackages;
}

- (BOOL)resizeFromLayer:(CAEAGLLayer *)layer {

    if (_framebuffer) {

        glDeleteFramebuffers(1, &_framebuffer);
        _framebuffer = 0;
    }

    if (_colorbuffer) {

        glDeleteRenderbuffers(1, &_colorbuffer);
        _colorbuffer = 0;
    }

    if (_depthbuffer) {

        glDeleteRenderbuffers(1, &_depthbuffer);
        _depthbuffer = 0;
    }


    // framebuffer
    glGenFramebuffers(1, &_framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _framebuffer);

    // rgb buffer
    glGenRenderbuffers(1, &_colorbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorbuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorbuffer);
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:layer];
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_backingWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_backingHeight);

    // z-buffer
    glGenRenderbuffers(1, &_depthbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _depthbuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, _backingWidth, _backingHeight);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _depthbuffer);

    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {

        ALog(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
        return NO;
    }

    [self setupGLWithFramebufferSize:layer.bounds.size];

    return YES;
}

- (void)setupGLWithFramebufferSize:(CGSize)framebufferSize {

    // GL shite
    glEnable(GL_TEXTURE_2D);
    glEnable(GL_DEPTH_TEST);
    glFrontFace(GL_CCW);

    // Configure Projection
    GLfloat near = 0.1;
    GLfloat far = 100.0;
    GLfloat fieldOfViewInDegreesY = 90.0;
    CGFloat aspectRatioWidthOverHeight = framebufferSize.width / framebufferSize.height;
    [self.rendererHelper perspectiveProjectionWithFieldOfViewInDegreesY:fieldOfViewInDegreesY
                                             aspectRatioWidthOverHeight:aspectRatioWidthOverHeight
                                                                   near:near
                                                                    far:far];
    // Aim camera
    EISVector3D eye;
    EISVector3D target;
    EISVector3D approximateUp;

    EISVector3DSet(eye, 0, 0, 0);
    EISVector3DSet(target, 0, 0, -1);
    EISVector3DSet(approximateUp, 0, 1, 0);

    [self.rendererHelper placeCameraAtLocation:eye target:target up:approximateUp];

    // Configure rendering surface
    CGFloat dimen = (aspectRatioWidthOverHeight < 1) ? aspectRatioWidthOverHeight : 1;
    self.renderSurface = [[[EIQuad alloc] initWithHalfSize:CGSizeMake(dimen, dimen)] autorelease];

    // Configure shader
    self.shaderProgram = [EIShaderManager shaderProgramWithShaderPrefix:@"EISTextureShader"];
//    self.shaderProgram = [GLRender shaderProgramWithShaderPrefix:@"EISGaussianBlurEastWest"];
    glUseProgram(self.shaderProgram.programHandle);

    // Get shaderProgram uniform pointers
    self.uniforms[Uniform_ProjectionViewModel] = glGetUniformLocation(self.shaderProgram.programHandle, "projectionViewModelMatrix");
    self.uniforms[Uniform_ViewModelMatrix] = glGetUniformLocation(self.shaderProgram.programHandle, "viewModelMatrix");
    self.uniforms[Uniform_ModelMatrix] = glGetUniformLocation(self.shaderProgram.programHandle, "modelMatrix");
    self.uniforms[Uniform_SurfaceNormalMatrix] = glGetUniformLocation(self.shaderProgram.programHandle, "normalMatrix");


    // Configure FBO
    dimen = MIN(framebufferSize.width, framebufferSize.height);
    EITextureOldSchool *fboTexture = [[[EITextureOldSchool alloc] initFBOTextureWidth:(NSUInteger) dimen
                                                                               height:(NSUInteger) dimen] autorelease];

    FBOTextureTarget *fboTextureTarget = [[[FBOTextureTarget alloc] initWithFBOTexture:fboTexture] autorelease];

    EIQuad *renderSurface = [[[EIQuad alloc] initWithHalfSize:CGSizeMake(1, 1)] autorelease];

    EIRendererHelper *fboRendererHelper = [[[EIRendererHelper alloc] init] autorelease];
    [fboRendererHelper.renderables setObject:[self.rendererHelper.renderables objectForKey:@"hero" ] forKey:@"hero" ];
    [fboRendererHelper.renderables setObject:[self.rendererHelper.renderables objectForKey:@"matte"] forKey:@"matte"];

    self.fboTextureTargetRenderer = [[[FBOTextureTargetRenderer alloc] initWithRenderSurface:renderSurface
                                                                            fboTextureTarget:fboTextureTarget
                                                                              rendererHelper:fboRendererHelper] autorelease];

}

- (void) render {

    [EAGLContext setCurrentContext:_context];

    // render to texture
    [self.fboTextureTargetRenderer render];

    // clear all current texture bindings
    glBindTexture(GL_TEXTURE_2D, 0);


    glBindFramebuffer(GL_FRAMEBUFFER, _framebuffer);
    glViewport(0, 0, _backingWidth, _backingHeight);

    glEnable(GL_BLEND);

    // Use with Photoshop created transparent PNG images which have pre-multiplied alpha
    // Porter-Duff "over" operation
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);

    // DO NOT Use with Photoshop created transparent PNG images which have pre-multiplied alpha
    // DO NOT Use with Photoshop created transparent PNG images which have pre-multiplied alpha
    // Using this produces a dark rim at the alpha edge.
//    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    // DO NOT Use with Photoshop created transparent PNG images which have pre-multiplied alpha
    // DO NOT Use with Photoshop created transparent PNG images which have pre-multiplied alpha

    glClearColor(1.0, 1.0, 1.0, 1.0);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);


    TextureShaderSetup textureShaderSetup = [[EIShaderManager sharedShaderManager].shaderSetupBlocks objectForKey:@"textureShaderSetup"];
    textureShaderSetup(self.shaderProgram.programHandle, self.fboTextureTargetRenderer.fboTextureTarget.fboTexture);

//    GaussianBlurShaderSetup gaussianBlurShaderSetup = [[EIShaderManager sharedShaderManager].shaderSetupBlocks objectForKey:@"gaussianBlurShaderSetup"];
//    gaussianBlurShaderSetup(self.shaderProgram.programHandle, self.fboTextureTargetRenderer.fboTextureTarget.fboTexture);

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

	// This application only creates a single color renderbuffer which is already bound at this point.
	// This call is redundant, but needed if dealing with multiple renderbuffers.
    glBindRenderbuffer(GL_RENDERBUFFER, _colorbuffer);
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}

@end
