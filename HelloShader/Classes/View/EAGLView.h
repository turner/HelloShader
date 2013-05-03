//
//  EAGLView.h
//  HelloiPadGLSL
//
//  Created by turner on 3/23/10.
//  Copyright Douglass Turner Consulting 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class ES2Renderer;

@interface EAGLView : UIView {    
	
@private
	
    // Use of the CADisplayLink class is the preferred method for controlling your animation timing.
    // CADisplayLink will link to the main display and fire every vsync when added to a given run-loop.
    // The NSTimer class is used only as fallback when running on a pre 3.1 device where CADisplayLink
    // isn't available.
    id				m_displayLink;
	ES2Renderer		*m_renderer;
    BOOL			m_animating;
	NSInteger		animationFrameInterval;
	
}

@property(nonatomic,retain)id						displayLink;
@property(nonatomic,retain)ES2Renderer				*renderer;
@property(nonatomic,assign,getter=isAnimating)BOOL	animating;
@property (nonatomic) NSInteger						animationFrameInterval;

- (void)startAnimation;
- (void)stopAnimation;
- (void)drawView:(id)sender;

@end
