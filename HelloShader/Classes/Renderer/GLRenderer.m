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

// uniform index
enum {
    Uniform_ProjectionViewModel,
    Uniform_ViewModelMatrix,
    Uniform_ModelMatrix,
    Uniform_SurfaceNormalMatrix,
    UniformCount
};

GLint uniforms[UniformCount];

// attribute index
enum {
    Attribute_VertexXYZ,
    Attribute_VertexST
};

@interface GLRenderer ()
@property(nonatomic, retain) EIQuad *renderSurface;
- (void)setupGLWithFrameBufferSize:(CGSize)size;
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

@synthesize texturePackages = _texturePackages;
@synthesize shaderProgram = _shaderProgram;
@synthesize rendererHelper = _rendererHelper;
@synthesize fboTextureRenderer;
@synthesize renderSurface;

- (void) dealloc {

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

- (BOOL) resizeFromLayer:(CAEAGLLayer *)layer {

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

    [self setupGLWithFrameBufferSize:layer.bounds.size];

    return YES;
}

- (void)setupGLWithFrameBufferSize:(CGSize)size {

    // GL futzing
    glEnable(GL_TEXTURE_2D);
    glEnable(GL_DEPTH_TEST);
    glFrontFace(GL_CCW);
    glEnable (GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    // Build Projection
    GLfloat near					=   0.1;
    GLfloat far						= 100.0;
    GLfloat fieldOfViewInDegreesY	=  90.0;
    CGFloat aspectRatioWidthOverHeight = size.width/size.height;
    [self.rendererHelper perspectiveProjectionWithFieldOfViewInDegreesY:fieldOfViewInDegreesY
                                             aspectRatioWidthOverHeight:aspectRatioWidthOverHeight
                                                                   near:near
                                                                    far:far];


    // Aim Camera
    EISVector3D eye;
    EISVector3D target;
    EISVector3D up;

    EISVector3DSet(eye,	   0, 0,  0);
    EISVector3DSet(target, 0, 0, -1);
    EISVector3DSet(up,	   0, 1,  0);

    [self.rendererHelper placeCameraAtLocation:eye target:target up:up];

    // Rendering surface
    CGFloat dimen = (aspectRatioWidthOverHeight < 1) ? aspectRatioWidthOverHeight : 1;
    self.renderSurface = [[[EIQuad alloc] initWithHalfSize:CGSizeMake(dimen, dimen)] autorelease];




    // Construct two FBO. One for ease-west blurring and one for north-south blurring
    EITextureOldSchool *fboRenderTexture = [[[EITextureOldSchool alloc] initFBORenderTextureRGBA8Width:(NSUInteger) (2 * self.renderSurface.halfSize.width) height:(NSUInteger) (2 * self.renderSurface.halfSize.width)] autorelease];
    FBOTextureRenderTarget *fboTextureRenderTarget = [[[FBOTextureRenderTarget alloc] initWithTextureTarget:fboRenderTexture] autorelease];

    EISRendererHelper *rendererHelper = [[[EISRendererHelper alloc] init] autorelease];
    self.fboTextureRenderer = [[[FBOTextureRenderer alloc] initWithRenderSurface:self.renderSurface fboTextureRenderTarget:fboTextureRenderTarget rendererHelper:rendererHelper] autorelease];
    self.fboTextureRenderer.shaderProgram = [self shaderProgramWithShaderPrefix:@"TEITexturePairShader"];













    glUseProgram(_shaderProgram);

    // Get shaderProgram uniform pointers
    uniforms[Uniform_ProjectionViewModel] = glGetUniformLocation(_shaderProgram, "projectionViewModelMatrix");
    uniforms[Uniform_ViewModelMatrix    ] = glGetUniformLocation(_shaderProgram, "viewModelMatrix");
    uniforms[Uniform_ModelMatrix        ] = glGetUniformLocation(_shaderProgram, "modelMatrix");
    uniforms[Uniform_SurfaceNormalMatrix] = glGetUniformLocation(_shaderProgram, "normalMatrix");

    // Attach textureTarget(s) to shaderProgram
    EITextureOldSchool *t = nil;

    // Texture unit 0
    t = (EITextureOldSchool *)[self.rendererHelper.renderables objectForKey:@"texture_0"];
    t.glslSampler = (GLuint)glGetUniformLocation(_shaderProgram, "myTexture_0");

//    glActiveTexture(GL_TEXTURE0 + 0);
//    t = (EITextureOldSchool *)[self.rendererHelper.renderables objectForKey:@"texture_0"];
//    glBindTexture(GL_TEXTURE_2D, t.name);
    glUniform1i(t.glslSampler, 0);

    // Texture unit 1
    t = (EITextureOldSchool *)[self.rendererHelper.renderables objectForKey:@"texture_1"];
    t.glslSampler = (GLuint)glGetUniformLocation(_shaderProgram, "myTexture_1");

//    glActiveTexture(GL_TEXTURE0 + 1);
//    t = (EITextureOldSchool *)[self.rendererHelper.renderables objectForKey:@"texture_1"];
//    glBindTexture(GL_TEXTURE_2D, t.name);
    glUniform1i(t.glslSampler, 1);

    // clear all current texture bindings
    glBindTexture(GL_TEXTURE_2D, 0);


}

- (void) render {

    [EAGLContext setCurrentContext:_context];
    glBindFramebuffer(GL_FRAMEBUFFER, _framebuffer);
    glViewport(0, 0, _backingWidth, _backingHeight);
    
    glClearColor(0.25f, 0.25f, 0.25f, 1.0f);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
	static float angle = 0.0;
    EISMatrix4x4 rotationMatrix;
    EISMatrix4x4SetZRotationUsingDegrees(rotationMatrix, 0);
//    EISMatrix4x4SetZRotationUsingDegrees(rotationMatrix, angle);
	angle += 1.0;
	
    EISMatrix4x4 translationMatrix;
    EISMatrix4x4SetTranslation(translationMatrix, 0, 0, 0);

    EISMatrix4x4 xform;
    EISMatrix4x4Multiply(translationMatrix, rotationMatrix, xform);

    // clear all current texture bindings
    glBindTexture(GL_TEXTURE_2D, 0);

    glUseProgram(_shaderProgram);

    EITextureOldSchool *t;
    glActiveTexture(GL_TEXTURE0 + 0);
    t = (EITextureOldSchool *)[self.rendererHelper.renderables objectForKey:@"texture_0"];
    glBindTexture(GL_TEXTURE_2D, t.name);

    glActiveTexture(GL_TEXTURE0 + 1);
    t = (EITextureOldSchool *)[self.rendererHelper.renderables objectForKey:@"texture_1"];
    glBindTexture(GL_TEXTURE_2D, t.name);


    // M - World space
	[self.rendererHelper setModelTransform:xform];
	glUniformMatrix4fv(uniforms[Uniform_ModelMatrix], 1, NO, (GLfloat *)[self.rendererHelper modelTransform]);
	
	// The surface normal transform is the inverse of M
	glUniformMatrix4fv(uniforms[Uniform_SurfaceNormalMatrix], 1, NO, (GLfloat *)[self.rendererHelper surfaceNormalTransform]);

	// V * M - Eye space
    EISMatrix4x4Multiply([self.rendererHelper viewTransform], [self.rendererHelper modelTransform], [self.rendererHelper viewModelTransform]);
	glUniformMatrix4fv(uniforms[Uniform_ViewModelMatrix], 1, NO, (GLfloat *)[self.rendererHelper viewModelTransform]);
	
	// P * V * M - Projection space
    EISMatrix4x4Multiply([self.rendererHelper projection], [self.rendererHelper viewModelTransform], [self.rendererHelper projectionViewModelTransform]);
    glUniformMatrix4fv(uniforms[Uniform_ProjectionViewModel], 1, NO, (GLfloat *)[self.rendererHelper projectionViewModelTransform]);

	glEnableVertexAttribArray(Attribute_VertexXYZ);
	glEnableVertexAttribArray(Attribute_VertexST);

    glVertexAttribPointer(Attribute_VertexXYZ,		3, GL_FLOAT,			0, 0, self.renderSurface.vertices);
    glVertexAttribPointer(Attribute_VertexST,		2, GL_FLOAT,			0, 0, [EISRendererHelper verticesST]);








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
