//
//  EIViewController.m
//  HelloShader
//
//  Created by Douglass Turner on 5/3/13.
//  Copyright (c) 2013 Elastic Image Software. All rights reserved.
//

#import "EIViewController.h"
#import "GLView.h"
#import "EITexture.h"
#import "GLRenderer.h"
#import "EISRendererHelper.h"
#import "FBOTextureRenderTarget.h"
#import "FBOTextureRenderer.h"

@interface EIViewController ()
@property(nonatomic, retain) GLRenderer *renderer;
@end

@implementation EIViewController

@synthesize renderer;

- (void)dealloc {

    self.renderer = nil;

    [super dealloc];
}

- (void)viewDidLoad {

    self.renderer = [[[GLRenderer alloc] initWithContext:[[[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2] autorelease]
                                            renderHelper:[[[EISRendererHelper alloc] init] autorelease]] autorelease];

//    NSString *shaderPrefix = @"TEITexturePairShader";
    NSString *shaderPrefix = @"TEITextureShader";
//    NSString *shaderPrefix = @"ShowST";
    self.renderer.shaderProgram = [self.renderer shaderProgramWithPrefix:shaderPrefix];


    GLView *glView = (GLView *)self.view;
    glView.renderer = self.renderer;
    
	EITexture *texture_0 = [[ [EITexture alloc] initWithImageFile:@"twitter_fail_whale_red_channnel_knockout" extension:@"png" mipmap:YES ] autorelease];
	[self.renderer.rendererHelper.renderables setObject:texture_0 forKey:@"texture_0"];
	
	EITexture *texture_1 = [[ [EITexture alloc] initWithImageFile:@"mandrill" extension:@"png" mipmap:YES ] autorelease];
	[self.renderer.rendererHelper.renderables setObject:texture_1 forKey:@"texture_1"];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

@end
