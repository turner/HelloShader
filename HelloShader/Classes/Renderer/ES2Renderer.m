//
//  ES2Renderer.m
//  HelloiPhoneiPodTouchPanorama
//
//  Created by turner on 2/25/10.
//  Copyright Douglass Turner Consulting 2010. All rights reserved.
//

#import "ES2Renderer.h"
#import "TEIRendererHelper.h"
#import "ConstantsAndMacros.h"
#import "JLMMatrixLibrary.h"
#import	"TEITexture.h"
#import "TEIRendererHelper.h"

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

@interface ES2Renderer (PrivateMethods)
- (BOOL) loadShaders;
- (BOOL) compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL) linkProgram:(GLuint)prog;
- (BOOL) validateProgram:(GLuint)prog;
@end

@implementation ES2Renderer

@synthesize rendererHelper = m_rendererHelper;

- (void) dealloc {
	
    [m_rendererHelper release], m_rendererHelper = nil;
	
	if (m_framebuffer) {
		
		glDeleteFramebuffers(1, &m_framebuffer);
		m_framebuffer = 0;
	}
	
	if (m_colorbuffer) {
		
		glDeleteRenderbuffers(1, &m_colorbuffer);
		m_colorbuffer = 0;
	}
	
	if (m_depthbuffer) {
		
		glDeleteRenderbuffers(1, &m_depthbuffer);
		m_depthbuffer = 0;
	}
	
	if (m_program) {
		
		glDeleteProgram(m_program);
		m_program = 0;
	}
	
	if ([EAGLContext currentContext] == m_context) [EAGLContext setCurrentContext:nil];
	
	[m_context release];
	m_context = nil;
	
	[super dealloc];
}

- (id) init {
	
	if (self = [super init]) {
		
		m_backingWidth = -1;
		m_backingHeight = -1;
		
		NSLog(@"ES2 Renderer - init - backing size (%d %d)", m_backingWidth, m_backingHeight);
		
		m_rendererHelper = [[TEIRendererHelper alloc] init];
		
		m_context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        
        if (!m_context || ![EAGLContext setCurrentContext:m_context] || ![self loadShaders]) {
			
            [self release];
			
            return nil;
        } // if (!m_context || ![EAGLContext setCurrentContext:m_context] || ![self loadShaders])
        
	} // if (self = [super init])
	
	return self;
}

- (void) render {
		
    [EAGLContext setCurrentContext:m_context];
    glBindFramebuffer(GL_FRAMEBUFFER, m_framebuffer);
    glViewport(0, 0, m_backingWidth, m_backingHeight);
    
//    glClearColor(0.25f, 0.25f, 0.25f, 1.0f);
    glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
	static float angle = 0.0;
	M3DMatrix44f rotation;
	JLMMatrix3DSetRotationByDegrees(rotation, angle, 0.0, 0.0, 1.0);
	angle += 1.0;	
	
	static float t = 0.0f;
	M3DMatrix44f translation;
	JLMMatrix3DSetTranslation(translation, 0.0, 0.0, (1.0) * cosf(t/4.0));
	t += 0.075f/3.0;	
    
	M3DMatrix44f xform;
	JLMMatrix3DMultiply(translation, rotation, xform);

	
    glUseProgram(m_program);
		
	// M - World space
	[self.rendererHelper setModelTransform:xform];
	glUniformMatrix4fv(uniforms[ModelMatrixUniformHandle], 1, NO, (GLfloat *)[self.rendererHelper modelTransform]);
	
	// The surface normal transform is the inverse of M
	glUniformMatrix4fv(uniforms[SurfaceNormalMatrixUniformHandle], 1, NO, (GLfloat *)[self.rendererHelper surfaceNormalTransform]);

	// V * M - Eye space
	JLMMatrix3DMultiply([self.rendererHelper viewTransform], [self.rendererHelper modelTransform], [self.rendererHelper viewModelTransform]);
	glUniformMatrix4fv(uniforms[ViewModelMatrixUniformHandle], 1, NO, (GLfloat *)[self.rendererHelper viewModelTransform]);
	
	// P * V * M - Projection space
	JLMMatrix3DMultiply([self.rendererHelper projection], [self.rendererHelper viewModelTransform], [self.rendererHelper projectionViewModelTransform]);
	glUniformMatrix4fv(uniforms[ProjectionViewModelUniformHandle], 1, NO, (GLfloat *)[self.rendererHelper projectionViewModelTransform]);
	
	
	glEnableVertexAttribArray(VertexXYZAttributeHandle);
	glEnableVertexAttribArray(VertexSTAttributeHandle);
	glEnableVertexAttribArray(VertexRGBAAttributeHandle);
		
	glVertexAttribPointer(VertexXYZAttributeHandle,		3, GL_FLOAT,			0, 0, verticesXYZ);
	glVertexAttribPointer(VertexSTAttributeHandle,		2, GL_FLOAT,			0, 0, verticesST);
	glVertexAttribPointer(VertexRGBAAttributeHandle,	4, GL_UNSIGNED_BYTE,	1, 0, verticesRGBA);
	
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

	glDisableVertexAttribArray(VertexXYZAttributeHandle);
	glDisableVertexAttribArray(VertexSTAttributeHandle);
	glDisableVertexAttribArray(VertexRGBAAttributeHandle);
	
	
	
	
	
	// This application only creates a single color renderbuffer which is already bound at this point.
	// This call is redundant, but needed if dealing with multiple renderbuffers.
    glBindRenderbuffer(GL_RENDERBUFFER, m_colorbuffer);
    [m_context presentRenderbuffer:GL_RENDERBUFFER];
}

- (BOOL) resizeFromLayer:(CAEAGLLayer *)layer {
	
	NSLog(@"ES2Renderer - resize From Layer");
	
	if (m_framebuffer) {
		
		glDeleteFramebuffers(1, &m_framebuffer);
		m_framebuffer = 0;
	}
	
	if (m_colorbuffer) {
		
		glDeleteRenderbuffers(1, &m_colorbuffer);
		m_colorbuffer = 0;
	}
	
	if (m_depthbuffer) {
		
		glDeleteRenderbuffers(1, &m_depthbuffer);
		m_depthbuffer = 0;
	}
	
	
	// framebuffer
	glGenFramebuffers(1, &m_framebuffer);
	glBindFramebuffer(GL_FRAMEBUFFER, m_framebuffer);
	
	// rgb buffer
	glGenRenderbuffers(1, &m_colorbuffer);
	glBindRenderbuffer(GL_RENDERBUFFER, m_colorbuffer);
	glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, m_colorbuffer);
    [m_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:layer];
	glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &m_backingWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &m_backingHeight);
	
	// z-buffer
	glGenRenderbuffers(1, &m_depthbuffer);
	glBindRenderbuffer(GL_RENDERBUFFER, m_depthbuffer);
	glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, m_backingWidth, m_backingHeight);	
	glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, m_depthbuffer);
	
    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
		
		NSLog(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
        return NO;
    }
    
	[self setupGLView:layer.bounds.size];
	
    return YES;
}

- (void) setupGLView:(CGSize)size {
	
	NSLog(@"ES2 Renderer - setup GLView");
	
	// Associate textures with shaders
	glUseProgram(m_program);
	
	// Associate shader uniform variables with application space variables
    uniforms[ProjectionViewModelUniformHandle	] = glGetUniformLocation(m_program, "myProjectionViewModelMatrix");
    uniforms[ViewModelMatrixUniformHandle		] = glGetUniformLocation(m_program, "myViewModelMatrix");
    uniforms[ModelMatrixUniformHandle			] = glGetUniformLocation(m_program, "myModelMatrix");
    uniforms[SurfaceNormalMatrixUniformHandle	] = glGetUniformLocation(m_program, "mySurfaceNormalMatrix");
    
	
	TEITexture *t = nil;
	
	t = (TEITexture *)[self.rendererHelper.renderables objectForKey:@"texture_0"];
	t.location = glGetUniformLocation(m_program, "myTexture_0");
	
	t = (TEITexture *)[self.rendererHelper.renderables objectForKey:@"texture_1"];
	t.location = glGetUniformLocation(m_program, "myTexture_1");
	
	
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
	M3DVector3f eye;
	M3DVector3f target;
	M3DVector3f up;
	m3dLoadVector3f(eye,	0.0f, 0.0f,   2.0);
	m3dLoadVector3f(target, 0.0f, 0.0f,  -1.0f);
	m3dLoadVector3f(up,		0.0f, 1.0f,   0.0f);
	
	[self.rendererHelper placeCameraAtLocation:eye target:target up:up];
	
	// Texture unit 0
	t = (TEITexture *)[self.rendererHelper.renderables objectForKey:@"texture_0"];
	glActiveTexture( GL_TEXTURE0 );
	glBindTexture(GL_TEXTURE_2D, t.name);
	glUniform1i(t.location, 0);
	
	// Texture unit 1
	t = (TEITexture *)[self.rendererHelper.renderables objectForKey:@"texture_1"];
	glActiveTexture( GL_TEXTURE1 );
	glBindTexture(GL_TEXTURE_2D, t.name);
	glUniform1i(t.location, 1);
	
}

- (BOOL) loadShaders {
	
	NSLog(@"ES2 Renderer - load Shaders");
	
    m_program = glCreateProgram();
	
	// Compile vertex and fragment shaders
	NSString *vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"ShowXYRaster" ofType:@"vsh"];
//	NSString *vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"TEITexturePairShader" ofType:@"vsh"];
//	NSString *vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"TEITextureShader" ofType:@"vsh"];
//	NSString *vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"ShowST" ofType:@"vsh"];
	GLuint vertShader;
	if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {
		
		NSLog(@"ES2 Renderer - load Shaders: Failed to compile vertex shader");
		
		return FALSE;
		
	} // if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname])
	
	NSString *fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"ShowXYRaster" ofType:@"fsh"];
//	NSString *fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"TEITexturePairShader" ofType:@"fsh"];
//	NSString *fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"TEITextureShader" ofType:@"fsh"];
//	NSString *fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"ShowST" ofType:@"fsh"];
	GLuint fragShader;
	if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {
		
		NSLog(@"ES2 Renderer - load Shaders: Failed to compile fragment shader");
		
		return FALSE;
		
	} // if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname])
	
    // Attach vertex and fragment shaders to program
    glAttachShader(m_program, vertShader);
    glAttachShader(m_program, fragShader);
    
	// Bind attributes between application and shaders
    glBindAttribLocation(m_program, VertexXYZAttributeHandle,	"myVertexXYZ");
	glBindAttribLocation(m_program, VertexSTAttributeHandle,	"myVertexST");
    glBindAttribLocation(m_program, VertexRGBAAttributeHandle,	"myVertexRGBA");
    
	// Link shader program
	if (![self linkProgram:m_program]) {
		
		NSLog(@"ES2 Renderer - load Shaders: Failed to link program: %d", m_program);
		
		return FALSE;
		
	} // if (![self linkProgram:m_program]) {
	
    // release vertex and fragment shaders
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
