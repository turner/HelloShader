//
//  GLRenderer.m
//  HelloiPhoneiPodTouchPanorama
//
//  Created by turner on 2/25/10.
//  Copyright Douglass Turner Consulting 2010. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "GLRenderer.h"
#import "EISRendererHelper.h"
#import "EITexture.h"
#import "Logging.h"
#include "EISVectorMatrix.h"

static const GLfloat verticesST[] = {
	
	0.0f, 0.0f,
	1.0f, 0.0f,
	0.0f, 1.0f,
	1.0f, 1.0f,
};

static const GLfloat verticesXYZ[] = {
	-0.5f, -0.5f, 0.0f,
	 0.5f, -0.5f, 0.0f,
	-0.5f,  0.5f, 0.0f,
	 0.5f,  0.5f, 0.0f,
};

static const GLubyte verticesRGBA[] = {
	255, 255,   0, 255,
	0,   255, 255, 255,
	0,     0,   0, 255,
	255,   0, 255, 255,
};

// uniform index
enum {
	ProjectionViewModelUniformHandle,
	ViewModelMatrixUniformHandle,
	ModelMatrixUniformHandle,
	SurfaceNormalMatrixUniformHandle,
    UniformCount
};

GLint uniforms[UniformCount];

// attribute index
enum {
    VertexXYZAttributeHandle,
    VertexSTAttributeHandle,
    VertexRGBAAttributeHandle,
    VertexSurfaceNormalAttributeHandle,
    AttributeCount
};

@interface GLRenderer (PrivateMethods)
- (BOOL) loadShaders;
- (BOOL) compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL) linkProgram:(GLuint)prog;
- (BOOL) validateProgram:(GLuint)prog;
@end

@implementation GLRenderer {

    EAGLContext *_context;

    GLint _backingWidth;
    GLint _backingHeight;

    GLuint _framebuffer;
    GLuint _colorbuffer;
    GLuint _depthbuffer;

    GLuint _program;

    NSMutableDictionary *_texturePackages;
}

@synthesize rendererHelper;
@synthesize texturePackages = _texturePackages;

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
	
	if (_program) {
		
		glDeleteProgram(_program);
		_program = 0;
	}
	
	if ([EAGLContext currentContext] == _context) [EAGLContext setCurrentContext:nil];
	[_context release]; _context = nil;

    self.texturePackages = nil;
    self.rendererHelper = nil;

    [super dealloc];
}

- (id) init {
	
	if (self = [super init]) {
		
		_backingWidth = -1;
		_backingHeight = -1;

        self.rendererHelper = [[[EISRendererHelper alloc] init] autorelease];
		
		_context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        
        if (!_context || ![EAGLContext setCurrentContext:_context] || ![self loadShaders]) {
			
            [self release];
			
            return nil;
        }
	}
	
	return self;
}

-(NSMutableDictionary *)texturePackages {

    if (nil == _texturePackages) self.texturePackages = [NSMutableDictionary dictionary];

    return _texturePackages;
}

- (void) setupGLView:(CGSize)size {

    glUseProgram(_program);

    uniforms[ProjectionViewModelUniformHandle	] = glGetUniformLocation(_program, "myProjectionViewModelMatrix");
    uniforms[ViewModelMatrixUniformHandle		] = glGetUniformLocation(_program, "myViewModelMatrix");
    uniforms[ModelMatrixUniformHandle			] = glGetUniformLocation(_program, "myModelMatrix");
    uniforms[SurfaceNormalMatrixUniformHandle	] = glGetUniformLocation(_program, "mySurfaceNormalMatrix");


    glEnable(GL_TEXTURE_2D);
    glEnable(GL_DEPTH_TEST);
    glFrontFace(GL_CCW);
    glEnable (GL_BLEND);

    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    GLfloat near					=   0.1;
    GLfloat far						= 100.0;
    GLfloat fieldOfViewInDegreesY	=  90.0;

    [self.rendererHelper perspectiveProjectionWithFieldOfViewInDegreesY:fieldOfViewInDegreesY
                                             aspectRatioWidthOverHeight:size.width/size.height
                                                                   near:near
                                                                    far:far];


    // Aim the camera
    EISVector3D eye;
    EISVector3D target;
    EISVector3D up;
    EISVector3DSet(eye,	   0, 0,  2);
    EISVector3DSet(target, 0, 0, -1);
    EISVector3DSet(up,	   0, 1,  0);

    [self.rendererHelper placeCameraAtLocation:eye target:target up:up];






    EITexture *t = nil;

    // Texture unit 0
    t = (EITexture *)[self.rendererHelper.renderables objectForKey:@"texture_0"];
    t.glslSampler = (GLuint)glGetUniformLocation(_program, "myTexture_0");

    glActiveTexture(GL_TEXTURE0 + 0);
    t = (EITexture *)[self.rendererHelper.renderables objectForKey:@"texture_0"];
    glBindTexture(GL_TEXTURE_2D, t.name);
    glUniform1i(t.glslSampler, 0);

    glBindTexture(GL_TEXTURE_2D, 0);

    // Texture unit 1
    t = (EITexture *)[self.rendererHelper.renderables objectForKey:@"texture_1"];
    t.glslSampler = (GLuint)glGetUniformLocation(_program, "myTexture_1");

    glActiveTexture(GL_TEXTURE0 + 1);
    t = (EITexture *)[self.rendererHelper.renderables objectForKey:@"texture_1"];
    glBindTexture(GL_TEXTURE_2D, t.name);
    glUniform1i(t.glslSampler, 1);

    glBindTexture(GL_TEXTURE_2D, 0);


}

- (void) render {

    [EAGLContext setCurrentContext:_context];
    glBindFramebuffer(GL_FRAMEBUFFER, _framebuffer);
    glViewport(0, 0, _backingWidth, _backingHeight);
    
//    glClearColor(0.25f, 0.25f, 0.25f, 1.0f);
    glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
	static float angle = 0.0;
    EISMatrix4x4 rotation;
//	JLMMatrix3DSetRotationByDegrees(rotation, angle, 0.0, 0.0, 1.0);
    EISMatrix4x4SetZRotationUsingDegrees(rotation, angle);
	angle += 1.0;	
	
	static float r = 0.0f;
    EISMatrix4x4 translation;
//	JLMMatrix3DSetTranslation(translation, 0.0, 0.0, (1.0) * cosf(t/4.0));
    EISMatrix4x4SetTranslation(translation, 0, 0, (1.0) * cosf(r/4.0));
	r += 0.075f/3.0;

    EISMatrix4x4 xform;
//	JLMMatrix3DMultiply(translation, rotation, xform);
    EISMatrix4x4Multiply(translation, rotation, xform);

    glUseProgram(_program);

    EITexture *t;
    glActiveTexture(GL_TEXTURE0 + 0);
    t = (EITexture *)[self.rendererHelper.renderables objectForKey:@"texture_0"];
    glBindTexture(GL_TEXTURE_2D, t.name);

    glActiveTexture(GL_TEXTURE0 + 1);
    t = (EITexture *)[self.rendererHelper.renderables objectForKey:@"texture_1"];
    glBindTexture(GL_TEXTURE_2D, t.name);


    // M - World space
	[self.rendererHelper setModelTransform:xform];
	glUniformMatrix4fv(uniforms[ModelMatrixUniformHandle], 1, NO, (GLfloat *)[self.rendererHelper modelTransform]);
	
	// The surface normal transform is the inverse of M
	glUniformMatrix4fv(uniforms[SurfaceNormalMatrixUniformHandle], 1, NO, (GLfloat *)[self.rendererHelper surfaceNormalTransform]);

	// V * M - Eye space
//	JLMMatrix3DMultiply([self.rendererHelper viewTransform], [self.rendererHelper modelTransform], [self.rendererHelper viewModelTransform]);
    EISMatrix4x4Multiply([self.rendererHelper viewTransform], [self.rendererHelper modelTransform], [self.rendererHelper viewModelTransform]);
	glUniformMatrix4fv(uniforms[ViewModelMatrixUniformHandle], 1, NO, (GLfloat *)[self.rendererHelper viewModelTransform]);
	
	// P * V * M - Projection space
//	JLMMatrix3DMultiply([self.rendererHelper projection], [self.rendererHelper viewModelTransform], [self.rendererHelper projectionViewModelTransform]);
    EISMatrix4x4Multiply([self.rendererHelper projection], [self.rendererHelper viewModelTransform], [self.rendererHelper projectionViewModelTransform]);
    glUniformMatrix4fv(uniforms[ProjectionViewModelUniformHandle], 1, NO, (GLfloat *)[self.rendererHelper projectionViewModelTransform]);

	glEnableVertexAttribArray(VertexXYZAttributeHandle);
	glEnableVertexAttribArray(VertexSTAttributeHandle);
	glEnableVertexAttribArray(VertexRGBAAttributeHandle);
		
	glVertexAttribPointer(VertexXYZAttributeHandle,		3, GL_FLOAT,			0, 0, verticesXYZ);
	glVertexAttribPointer(VertexSTAttributeHandle,		2, GL_FLOAT,			0, 0, verticesST);
	glVertexAttribPointer(VertexRGBAAttributeHandle,	4, GL_UNSIGNED_BYTE,	1, 0, verticesRGBA);
	
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

	// This application only creates a single color renderbuffer which is already bound at this point.
	// This call is redundant, but needed if dealing with multiple renderbuffers.
    glBindRenderbuffer(GL_RENDERBUFFER, _colorbuffer);
    [_context presentRenderbuffer:GL_RENDERBUFFER];
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
    
	[self setupGLView:layer.bounds.size];
	
    return YES;
}

- (BOOL) loadShaders {

    ALog(@"");

    _program = glCreateProgram();

    NSString *shaderPrefix = @"TEITexturePairShader";
//    NSString *shaderPrefix = @"TEITextureShader";
//    NSString *shaderPrefix = @"ShowST";

	// Compile vertex and fragment shaders
	NSString *vertShaderPathname = [[NSBundle mainBundle] pathForResource:shaderPrefix ofType:@"vsh"];
	GLuint vertShader;
	if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {

        ALog(@"Failed to compile vertex shader");
		return FALSE;
	}
	
	NSString *fragShaderPathname = [[NSBundle mainBundle] pathForResource:shaderPrefix ofType:@"fsh"];
	GLuint fragShader;
	if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {

        ALog(@"Failed to compile fragment shader");
		return FALSE;
	}

    glAttachShader(_program, vertShader);
    glAttachShader(_program, fragShader);

    glBindAttribLocation(_program, VertexXYZAttributeHandle,	"myVertexXYZ");
	glBindAttribLocation(_program, VertexSTAttributeHandle,	"myVertexST");
    glBindAttribLocation(_program, VertexRGBAAttributeHandle,	"myVertexRGBA");

	if (![self linkProgram:_program]) {

        ALog(@"Failed to link program: %d", _program);
		return FALSE;
	}

    if (vertShader) glDeleteShader(vertShader);
    if (fragShader) glDeleteShader(fragShader);
	
	return TRUE;
}

- (BOOL) compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file {
	GLint status;
	const GLchar *source;
	
	source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
	if (!source)
	{
		NSLog(@"Failed to load vertex shader");
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
