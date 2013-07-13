//
// Created by turner on 7/8/13.
// Copyright (c) 2013 Elastic Image Software. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "EIShaderManager.h"
#import "EITextureOldSchool.h"
#import "EIAppDelegate.h"
#import "Logging.h"
#import "EIViewController.h"
#import "EIRenderer.h"
#import "EIRendererHelper.h"
#import "EIShader.h"
#import "EIGLUtils.h"


@interface EIShaderManager ()
@property(nonatomic, retain) EIRendererHelper *renderHelper;
- (void)loadShaderSetupBlocks;
@end

@implementation EIShaderManager

@synthesize shaderSetupBlocks = _shaderSetupBlocks;
@synthesize renderHelper = _renderHelper;

- (void)dealloc {

    self.renderHelper = nil;
    self.shaderSetupBlocks = nil;

    [super dealloc];
}

-(NSMutableDictionary *)shaderSetupBlocks {

    if (nil == _shaderSetupBlocks) {
        self.shaderSetupBlocks = [NSMutableDictionary dictionary];
        [self loadShaderSetupBlocks];
    }

    return _shaderSetupBlocks;
}

- (void)loadShaderSetupBlocks {

    TextureShaderSetup textureShaderSetup = ^(GLuint sh, EITextureOldSchool *hero) {

        GLint textureUnitIndex;
        glUseProgram(sh);

        hero.glslSampler = (GLuint)glGetUniformLocation(sh, "hero");
        glUniform1i(hero.glslSampler, 0);

        glGetUniformiv(sh, hero.glslSampler, &textureUnitIndex);

        glActiveTexture((GLenum)(GL_TEXTURE0 + textureUnitIndex));
        glBindTexture(GL_TEXTURE_2D, hero.name);
    };

    TexturePairShaderSetup texturePairShaderSetup = ^(GLuint sh, EITextureOldSchool *matte, EITextureOldSchool *hero) {

        GLint textureUnitIndex;
        glUseProgram(sh);

        // matte
        matte.glslSampler = (GLuint)glGetUniformLocation(sh, "matte");
        glUniform1i(matte.glslSampler, 0);

        glGetUniformiv(sh, matte.glslSampler, &textureUnitIndex);

        glActiveTexture((GLenum)(GL_TEXTURE0 + textureUnitIndex));
        glBindTexture(GL_TEXTURE_2D, matte.name);

        // hero
        hero.glslSampler = (GLuint)glGetUniformLocation(sh, "hero");
        glUniform1i(hero.glslSampler, 1);

        glGetUniformiv(sh, hero.glslSampler, &textureUnitIndex);

        glActiveTexture((GLenum)(GL_TEXTURE0 + textureUnitIndex));
        glBindTexture(GL_TEXTURE_2D, hero.name);
    };

    GaussianBlurShaderSetup gaussianBlurShaderSetup = ^(GLuint sh, EITextureOldSchool *hero) {

        GLint location;
        GLint textureUnitIndex;
        glUseProgram(sh);

        // hero
        hero.glslSampler = (GLuint)glGetUniformLocation(sh, "hero");
        glUniform1i(hero.glslSampler, 0);

        glGetUniformiv(sh, hero.glslSampler, &textureUnitIndex);

        glActiveTexture((GLenum)(GL_TEXTURE0 + textureUnitIndex));
        glBindTexture(GL_TEXTURE_2D, hero.name);

        float heroWidth  = hero.width;
        float heroHeight = hero.height;

        location = glGetUniformLocation(sh, "heroWidth");
        glUniform1f(location, heroWidth);

        location = glGetUniformLocation(sh, "heroHeight");
        glUniform1f(location, heroHeight);
    };

    [self.shaderSetupBlocks setObject:textureShaderSetup      forKey:@"textureShaderSetup"];
    [self.shaderSetupBlocks setObject:texturePairShaderSetup  forKey:@"texturePairShaderSetup"];
    [self.shaderSetupBlocks setObject:gaussianBlurShaderSetup forKey:@"gaussianBlurShaderSetup"];

}

+(EIShaderManager *)sharedShaderManager {

    static dispatch_once_t pred;
    static EIShaderManager *shared = nil;

    dispatch_once(&pred, ^{

        shared = [[EIShaderManager alloc] init];
    });

    return shared;

}

+ (EIShader *)shaderProgramWithShaderPrefix:(NSString *)shaderPrefix {

    EIShader *shaderProgram = [[[EIShader alloc] initWithShaderPrefix:shaderPrefix programHandle:glCreateProgram()] autorelease];

    // Compile vertex and fragment shaders
    NSString *vertShaderPathname = [[NSBundle mainBundle] pathForResource:shaderPrefix ofType:@"vsh"];
    GLuint vertShader;
    if (![EIShaderManager compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {

        ALog(@"Failed to compile vertex shaderProgram");
        return nil;
    }

    NSString *fragShaderPathname = [[NSBundle mainBundle] pathForResource:shaderPrefix ofType:@"fsh"];
    GLuint fragShader;
    if (![EIShaderManager compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {

        ALog(@"Failed to compile fragment shaderProgram");
        return nil;
    }

    glAttachShader(shaderProgram.programHandle, vertShader);
    glAttachShader(shaderProgram.programHandle, fragShader);

    glBindAttribLocation(shaderProgram.programHandle, Attribute_VertexXYZ, "vertexXYZ");
    glBindAttribLocation(shaderProgram.programHandle, Attribute_VertexST,	 "vertexST");

    if (![EIShaderManager linkProgram:shaderProgram.programHandle]) {

        ALog(@"Failed to link program: %d", shaderProgram.programHandle);
        return nil;
    }

    if (vertShader) glDeleteShader(vertShader);
    if (fragShader) glDeleteShader(fragShader);

    return shaderProgram;
}

+ (BOOL) compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file {
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
        GLchar *log = (GLchar *)malloc((size_t) logLength);
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

+ (BOOL) linkProgram:(GLuint)prog {
    GLint status;

    glLinkProgram(prog);

#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc((size_t) logLength);
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

+ (BOOL) validateProgram:(GLuint)prog {
    GLint logLength, status;

    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc((size_t) logLength);
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