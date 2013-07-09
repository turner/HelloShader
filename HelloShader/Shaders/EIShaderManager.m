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
#import "GLRenderer.h"
#import "EISRendererHelper.h"


@interface EIShaderManager ()
- (id)initWithRenderHelper:(EISRendererHelper *)renderHelper;
@property(nonatomic, retain) EISRendererHelper *renderHelper;
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

- (id)initWithRenderHelper:(EISRendererHelper *)renderHelper {
    
    self = [super init];
    if (nil != self) {
        self.renderHelper = renderHelper;        
    }
    return self;
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

        EIAppDelegate *appDelegate = (EIAppDelegate *)[UIApplication sharedApplication].delegate;
        shared = [[EIShaderManager alloc] initWithRenderHelper:appDelegate.viewController.renderer.rendererHelper];
    });

    return shared;

}

@end