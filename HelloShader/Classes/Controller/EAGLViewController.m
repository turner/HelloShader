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

@interface EAGLViewController (PrivateMethods)
- (NSString*)interfaceOrientationName:(UIInterfaceOrientation) interfaceOrientation;
- (NSString*)deviceOrientationName:(UIDeviceOrientation) deviceOrientation;
@end

@implementation EAGLViewController

- (void)dealloc {
	
    [super dealloc];
}

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

- (void)viewWillAppear:(BOOL)animated {
	
	NSLog(@"EAGL ViewController - view Will Appear");
	
}

- (void)viewDidAppear:(BOOL)animated {
	
	NSLog(@"EAGL ViewController - view Did Appear");
	
	UIDeviceOrientation currentDeviceOrientation = [UIDevice currentDevice].orientation;
	UIInterfaceOrientation currentInterfaceOrientation	= self.interfaceOrientation;
	
	NSLog(@"Current Interface: %@. Current Device: %@", 
		  [self interfaceOrientationName:currentInterfaceOrientation], 
		  [self deviceOrientationName:currentDeviceOrientation]);
	
}

- (void)viewWillDisappear:(BOOL)animated {
	
	NSLog(@"EAGL ViewController - view Will Disappear");
	
}

- (void)viewDidDisappear:(BOOL)animated {
	
	NSLog(@"EAGL ViewController - view Did Disappear");
	
}

- (void)viewDidUnload {
	
	NSLog(@"EAGL ViewController - view Did Unload");
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	
	return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	
	UIDeviceOrientation currentDeviceOrientation = [UIDevice currentDevice].orientation;
	UIInterfaceOrientation currentInterfaceOrientation	= self.interfaceOrientation;
	
	NSLog(@"EAGL ViewController - will Rotate To Interface: %@. Current Interface: %@. Current Device: %@", 
		  [self interfaceOrientationName:toInterfaceOrientation], 
		  [self interfaceOrientationName:currentInterfaceOrientation], 
		  [self deviceOrientationName:currentDeviceOrientation]);
	
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	
	UIDeviceOrientation currentDeviceOrientation = [UIDevice currentDevice].orientation;
	UIInterfaceOrientation currentInterfaceOrientation	= self.interfaceOrientation;
	
	NSLog(@"EAGL ViewController - did Rotate From Interface: %@. Current Interface: %@. Current Device: %@", 
		  [self interfaceOrientationName:fromInterfaceOrientation], 
		  [self interfaceOrientationName:currentInterfaceOrientation], 
		  [self deviceOrientationName:currentDeviceOrientation]);

}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (NSString*)interfaceOrientationName:(UIInterfaceOrientation) interfaceOrientation {
	
	NSString* result = nil;
	
	switch (interfaceOrientation) {
			
		case UIInterfaceOrientationPortrait:
			result = @"Portrait";
			break;
		case UIInterfaceOrientationPortraitUpsideDown:
			result = @"Portrait UpsideDown";
			break;
		case UIInterfaceOrientationLandscapeLeft:
			result = @"LandscapeLeft";
			break;
		case UIInterfaceOrientationLandscapeRight:
			result = @"LandscapeRight";
			break;
		default:
			result = @"Unknown Interface Orientation";
	}
	
	return result;
};

- (NSString*)deviceOrientationName:(UIDeviceOrientation) deviceOrientation {
	
	NSString* result = nil;
	
	switch (deviceOrientation) {
			
		case UIDeviceOrientationUnknown:
			result = @"Unknown";
			break;
		case UIDeviceOrientationPortrait:
			result = @"Portrait";
			break;
		case UIDeviceOrientationPortraitUpsideDown:
			result = @"Portrait UpsideDown";
			break;
		case UIDeviceOrientationLandscapeLeft:
			result = @"LandscapeLeft";
			break;
		case UIDeviceOrientationLandscapeRight:
			result = @"LandscapeRight";
			break;
		case UIDeviceOrientationFaceUp:
			result = @"FaceUp";
			break;
		case UIDeviceOrientationFaceDown:
			result = @"FaceDown";
			break;
		default:
			result = @"Unknown Device Orientation";
	}
	
	return result;
};




@end
