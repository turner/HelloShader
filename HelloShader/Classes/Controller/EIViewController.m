//
//  EIViewController.m
//  HelloShader
//
//  Created by Douglass Turner on 5/3/13.
//  Copyright (c) 2013 Elastic Image Software. All rights reserved.
//

#import "EIViewController.h"
#import "GLView.h"
#import "EITextureOldSchool.h"
#import "EIRenderer.h"
#import "EIRendererHelper.h"
#import "FBOTextureTarget.h"
#import "FBOTextureTargetRenderer.h"
#import "Logging.h"

@interface EIViewController ()
@end

@implementation EIViewController

@synthesize renderer;

- (void)dealloc {

    self.renderer = nil;

    [super dealloc];
}

- (void)viewDidLoad {

//    NSString * resourcePath = [[NSBundle mainBundle] resourcePath];
//
//    NSError * error = nil;
//    NSArray * contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:resourcePath error:&error];
//
//    if (nil != error) {
//        ALog(@"Error: %@", [error localizedDescription]);
//    } else {
//
//        for (NSString *string in contents) {
//
//            if (YES == [string hasSuffix:@"fsh"]) {
//                ALog(@"%@", string);
//            }
//
//        }
//
//    }

    self.renderer = [[[EIRenderer alloc] initWithContext:[[[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2] autorelease]
                                            renderHelper:[[[EIRendererHelper alloc] init] autorelease]] autorelease];

    GLView *glView = (GLView *)self.view;
    glView.renderer = self.renderer;
    
	EITextureOldSchool *matte = [[ [EITextureOldSchool alloc] initWithImageFile:@"twitter_fail_whale_red_channnel_knockout" extension:@"png" mipmap:YES ] autorelease];
    [self.renderer.rendererHelper.renderables setObject:matte forKey:@"matte"];
	
	EITextureOldSchool *hero = [[ [EITextureOldSchool alloc] initWithImageFile:@"mandrill" extension:@"png" mipmap:YES ] autorelease];
    [self.renderer.rendererHelper.renderables setObject:hero forKey:@"hero"];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

@end
