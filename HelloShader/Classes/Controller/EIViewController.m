//
//  EIViewController.m
//  HelloShader
//
//  Created by Douglass Turner on 5/3/13.
//  Copyright (c) 2013 Elastic Image Software. All rights reserved.
//

#import "EIViewController.h"
#import "Logging.h"
#import "EAGLView.h"
#import "TEITexture.h"
#import "ES2Renderer.h"
#import "TEIRendererHelper.h"

@interface EIViewController ()
- (NSString *)interfaceOrientationName:(UIInterfaceOrientation)interfaceOrientation;
- (NSString *)deviceOrientationName:(UIDeviceOrientation)deviceOrientation;
@end

@implementation EIViewController

- (void)viewDidLoad {

    ALog(@"");
    
    return;

	EAGLView *glView = (EAGLView *)self.view;
    
	TEITexture	*texture_0 = [[ [TEITexture alloc] initWithImageFile:@"twitter_fail_whale_red_channnel_knockout" extension:@"png" mipmap:YES ] autorelease];
	[glView.renderer.rendererHelper.renderables setObject:texture_0 forKey:@"texture_0"];
	
	TEITexture	*texture_1 = [[ [TEITexture alloc] initWithImageFile:@"mandrill" extension:@"png" mipmap:YES ] autorelease];
	[glView.renderer.rendererHelper.renderables setObject:texture_1 forKey:@"texture_1"];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	
	UIDeviceOrientation currentDeviceOrientation = [UIDevice currentDevice].orientation;
	UIInterfaceOrientation currentInterfaceOrientation	= self.interfaceOrientation;
	
	ALog(@"Will Rotate To Interface: %@. Current Interface: %@. Current Device: %@",
		  [self interfaceOrientationName:toInterfaceOrientation],
		  [self interfaceOrientationName:currentInterfaceOrientation],
		  [self deviceOrientationName:currentDeviceOrientation]);
	
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	
	UIDeviceOrientation currentDeviceOrientation = [UIDevice currentDevice].orientation;
	UIInterfaceOrientation currentInterfaceOrientation	= self.interfaceOrientation;

    ALog(@"Did Rotate From Interface: %@. Current Interface: %@. Current Device: %@",
		  [self interfaceOrientationName:fromInterfaceOrientation],
		  [self interfaceOrientationName:currentInterfaceOrientation],
		  [self deviceOrientationName:currentDeviceOrientation]);
    
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
