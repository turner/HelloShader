//
//  EAGLViewController.m
//  HelloiPhoneiPodTouchPanorama
//
//  Created by turner on 2/25/10.
//  Copyright 2010 Douglass Turner Consulting. All rights reserved.
//

#import "EAGLViewController.h"
#import "EAGLView.h"
#import "ES2Renderer.h"
#import "TEIRendererHelper.h"
#import "TEITexture.h"

@implementation EAGLViewController

- (void)loadView {
	
	NSLog(@"EAGL ViewController - view Did Load");
	
	CGRect frame = [[UIScreen mainScreen] applicationFrame];
	
	EAGLView *eaglView = [[[EAGLView alloc] initWithFrame:frame] autorelease];
	
	self.view = eaglView;
}

- (void)viewDidLoad {
	
	NSLog(@"EAGLViewController - view Did Load");
	
    [super viewDidLoad];
	
	EAGLView *glView = (EAGLView *)self.view;

	TEITexture	*texture_0 = [[ [TEITexture alloc] initWithImageFile:@"twitter_fail_whale_red_channnel_knockout" 
														  extension:@"png" 
															 mipmap:YES ] autorelease];
	[glView.renderer.rendererHelper.renderables setObject:texture_0 forKey:@"texture_0"];
	
	TEITexture	*texture_1 = [[ [TEITexture alloc] initWithImageFile:@"mandrill" 
														  extension:@"png" 
															 mipmap:YES ] autorelease];
	[glView.renderer.rendererHelper.renderables setObject:texture_1 forKey:@"texture_1"];

	
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {

    return YES;
}

@end
