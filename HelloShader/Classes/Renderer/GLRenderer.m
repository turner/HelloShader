//
//  GLRenderer.m
//  HelloShader
//
//  Created by turner on 2/25/10.
//  Copyright Douglass Turner Consulting 2010. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "GLRenderer.h"
#import "EISRendererHelper.h"
#import "EITextureOldSchool.h"
#import "Logging.h"
#import "EIQuad.h"
#import "FBOTextureRenderTarget.h"
#import "FBOTextureRenderer.h"
#import "EISGLUtils.h"

@interface GLRenderer ()
@property(nonatomic, retain) EIQuad *renderSurface;
@property(nonatomic) GLint *uniforms;
- (void)setupGLWithFramebufferSize:(CGSize)framebufferSize;

- (void)configureFBOWithFramebufferSize:(CGSize)framebufferSize;
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)prog;
- (BOOL)validateProgram:(GLuint)prog;
@end

@implementation GLRenderer {

    EAGLContext *_context;
    GLint _backingWidth;
    GLint _backingHeight;
    GLuint _framebuffer;
    GLuint _colorbuffer;
    GLuint _depthbuffer;
}

@synthesize uniforms = _uniforms;
@synthesize texturePackages = _texturePackages;
@synthesize shaderProgram = _shaderProgram;
@synthesize rendererHelper = _rendererHelper;
@synthesize renderSurface = _renderSurface;
@synthesize fboTextureRenderer;

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
	
	if (_shaderProgram) {
		glDeleteProgram(_shaderProgram);
		_shaderProgram = 0;
	}
	
	if ([EAGLContext currentContext] == _context) [EAGLContext setCurrentContext:nil];
	[_context release]; _context = nil;

    self.texturePackages = nil;
    self.rendererHelper = nil;
    self.renderSurface = nil;
    self.fboTextureRenderer = nil;

    [super dealloc];
}

-(id)initWithContext:(EAGLContext *)context renderHelper:(EISRendererHelper *)aRenderHelper {

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
    glEnable (GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);


    // Configure Projection
    GLfloat near					=   0.1;
    GLfloat far						= 100.0;
    GLfloat fieldOfViewInDegreesY	=  90.0;
    CGFloat aspectRatioWidthOverHeight = framebufferSize.width/ framebufferSize.height;
    [self.rendererHelper perspectiveProjectionWithFieldOfViewInDegreesY:fieldOfViewInDegreesY
                                             aspectRatioWidthOverHeight:aspectRatioWidthOverHeight
                                                                   near:near
                                                                    far:far];
    // Aim camera
    EISVector3D eye;
    EISVector3D target;
    EISVector3D approximateUp;

    EISVector3DSet(eye,	          0, 0,  0);
    EISVector3DSet(target,        0, 0, -1);
    EISVector3DSet(approximateUp, 0, 1,  0);

    [self.rendererHelper placeCameraAtLocation:eye target:target up:approximateUp];


    // Configure rendering surface
    CGFloat dimen = (aspectRatioWidthOverHeight < 1) ? aspectRatioWidthOverHeight : 1;
    self.renderSurface = [[[EIQuad alloc] initWithHalfSize:CGSizeMake(dimen, dimen)] autorelease];

    [self configureFBOWithFramebufferSize:framebufferSize];

    // Configure shader - this shader will just pass through whatever shading happens in the fbo shader
    self.shaderProgram = [self shaderProgramWithShaderPrefix:@"EISTextureShader"];
    glUseProgram(self.shaderProgram);

    // Get shaderProgram uniform pointers
    self.uniforms[Uniform_ProjectionViewModel] = glGetUniformLocation(self.shaderProgram, "projectionViewModelMatrix");
    self.uniforms[Uniform_ViewModelMatrix    ] = glGetUniformLocation(self.shaderProgram, "viewModelMatrix");
    self.uniforms[Uniform_ModelMatrix        ] = glGetUniformLocation(self.shaderProgram, "modelMatrix");
    self.uniforms[Uniform_SurfaceNormalMatrix] = glGetUniformLocation(self.shaderProgram, "normalMatrix");

}

- (void)configureFBOWithFramebufferSize:(CGSize)framebufferSize {

    NSUInteger dimen = (NSUInteger)MIN(framebufferSize.width, framebufferSize.height);
    EITextureOldSchool *fboRenderTexture = [[[EITextureOldSchool alloc] initFBORenderTextureRGBA8Width:dimen height:dimen] autorelease];
    FBOTextureRenderTarget *fboTextureRenderTarget = [[[FBOTextureRenderTarget alloc] initWithTextureTarget:fboRenderTexture] autorelease];

    EISRendererHelper *rendererHelper = [[[EISRendererHelper alloc] init] autorelease];
    [rendererHelper.renderables setObject:[self.rendererHelper.renderables objectForKey:@"hero" ] forKey:@"hero" ];
    [rendererHelper.renderables setObject:[self.rendererHelper.renderables objectForKey:@"matte"] forKey:@"matte"];

    self.fboTextureRenderer = [[[FBOTextureRenderer alloc] initWithRenderSurface:[[[EIQuad alloc] initWithHalfSize:CGSizeMake(1, 1)] autorelease]
                                                          fboTextureRenderTarget:fboTextureRenderTarget
                                                                  rendererHelper:rendererHelper] autorelease];

    // Configure fbo shader - specifically for texture pair shader
    NSString *shaderPrefix = @"EISTexturePairShader";
    self.fboTextureRenderer.shaderProgram = [self shaderProgramWithShaderPrefix:shaderPrefix];

    glUseProgram(self.fboTextureRenderer.shaderProgram);

    // Get shaderProgram uniform pointers
    self.fboTextureRenderer.uniforms[Uniform_ProjectionViewModel] = glGetUniformLocation(self.fboTextureRenderer.shaderProgram, "projectionViewModelMatrix");
    self.fboTextureRenderer.uniforms[Uniform_ViewModelMatrix    ] = glGetUniformLocation(self.fboTextureRenderer.shaderProgram, "viewModelMatrix");
    self.fboTextureRenderer.uniforms[Uniform_ModelMatrix        ] = glGetUniformLocation(self.fboTextureRenderer.shaderProgram, "modelMatrix");
    self.fboTextureRenderer.uniforms[Uniform_SurfaceNormalMatrix] = glGetUniformLocation(self.fboTextureRenderer.shaderProgram, "normalMatrix");

    // Attach textureTarget(s) to shaderProgram
    EITextureOldSchool *texas;

    // Texture unit 0
    texas = (EITextureOldSchool *)[self.rendererHelper.renderables objectForKey:@"hero"];
    texas.glslSampler = (GLuint)glGetUniformLocation(self.fboTextureRenderer.shaderProgram, "hero");
    glUniform1i(texas.glslSampler, 0);

    // Texture unit 1
    texas = (EITextureOldSchool *)[self.rendererHelper.renderables objectForKey:@"matte"];
    texas.glslSampler = (GLuint)glGetUniformLocation(self.fboTextureRenderer.shaderProgram, "matte");
    glUniform1i(texas.glslSampler, 1);
}

- (void) render {

    [EAGLContext setCurrentContext:_context];


    // render to texture
    [self.fboTextureRenderer render];


    // clear all current texture bindings
    glBindTexture(GL_TEXTURE_2D, 0);


    glBindFramebuffer(GL_FRAMEBUFFER, _framebuffer);
    glViewport(0, 0, _backingWidth, _backingHeight);
    
    glClearColor(0.25f, 0.25f, 0.25f, 1.0f);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);


    glUseProgram(self.shaderProgram);

    // Use the fbo texture target as the texture map for the shader used to render
    EITextureOldSchool *texas = self.fboTextureRenderer.fboTextureRenderTarget.textureTarget;
    texas.glslSampler = (GLuint)glGetUniformLocation(self.shaderProgram, "hero");
    glUniform1i(texas.glslSampler, 0);

    glActiveTexture(GL_TEXTURE0 + 0);
    glBindTexture(GL_TEXTURE_2D, texas.name);


    // M - World space - this defaults to the identify matrix
	glUniformMatrix4fv(self.uniforms[Uniform_ModelMatrix], 1, NO, (GLfloat *)[self.rendererHelper modelTransform]);
	
	// The surface normal transform is the inverse of M
	glUniformMatrix4fv(self.uniforms[Uniform_SurfaceNormalMatrix], 1, NO, (GLfloat *)[self.rendererHelper surfaceNormalTransform]);

	// V * M - Eye space
    EISMatrix4x4Multiply([self.rendererHelper viewTransform], [self.rendererHelper modelTransform], [self.rendererHelper viewModelTransform]);
	glUniformMatrix4fv(self.uniforms[Uniform_ViewModelMatrix], 1, NO, (GLfloat *)[self.rendererHelper viewModelTransform]);
	
	// P * V * M - Projection space
    EISMatrix4x4Multiply([self.rendererHelper projection], [self.rendererHelper viewModelTransform], [self.rendererHelper projectionViewModelTransform]);
    glUniformMatrix4fv(self.uniforms[Uniform_ProjectionViewModel], 1, NO, (GLfloat *)[self.rendererHelper projectionViewModelTransform]);

	glEnableVertexAttribArray(Attribute_VertexXYZ);
	glEnableVertexAttribArray(Attribute_VertexST);

    glVertexAttribPointer(Attribute_VertexXYZ, 3, GL_FLOAT, 0, 0, self.renderSurface.vertices);
    glVertexAttribPointer(Attribute_VertexST,  2, GL_FLOAT, 0, 0, [EISRendererHelper verticesST]);

    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

	// This application only creates a single color renderbuffer which is already bound at this point.
	// This call is redundant, but needed if dealing with multiple renderbuffers.
    glBindRenderbuffer(GL_RENDERBUFFER, _colorbuffer);
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}

- (GLuint)shaderProgramWithShaderPrefix:(NSString *)shaderPrefix {

    GLuint shaderProgram = glCreateProgram();

	// Compile vertex and fragment shaders
	NSString *vertShaderPathname = [[NSBundle mainBundle] pathForResource:shaderPrefix ofType:@"vsh"];
	GLuint vertShader;
	if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {

        ALog(@"Failed to compile vertex shaderProgram");
		return FALSE;
	}
	
	NSString *fragShaderPathname = [[NSBundle mainBundle] pathForResource:shaderPrefix ofType:@"fsh"];
	GLuint fragShader;
	if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {

        ALog(@"Failed to compile fragment shaderProgram");
		return FALSE;
	}

    glAttachShader(shaderProgram, vertShader);
    glAttachShader(shaderProgram, fragShader);

    glBindAttribLocation(shaderProgram, Attribute_VertexXYZ, "vertexXYZ");
	glBindAttribLocation(shaderProgram, Attribute_VertexST,	 "vertexST");

	if (![self linkProgram:shaderProgram]) {

        ALog(@"Failed to link program: %d", shaderProgram);
		return FALSE;
	}

    if (vertShader) glDeleteShader(vertShader);
    if (fragShader) glDeleteShader(fragShader);
	
	return shaderProgram;
}

- (BOOL) compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file {
	GLint status;
	const GLchar *source;
	
	source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
	if (!source)
	{
		NSLog(@"Failed to load vertex shaderProgram");
		return FALSE;
	}
	
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
	
#if defined(DEBUG)
	GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0)
	{
		glDeleteShader(*shader);
		return FALSE;
	}
	
	return TRUE;
}

- (BOOL) linkProgram:(GLuint)prog {
	GLint status;
	
	glLinkProgram(prog);

#if defined(DEBUG)
	GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0)
		return FALSE;
	
	return TRUE;
}

- (BOOL) validateProgram:(GLuint)prog {
	GLint logLength, status;
	
	glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0)
		return FALSE;
	
	return TRUE;
}

@end
