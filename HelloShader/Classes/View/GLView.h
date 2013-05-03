//
//  EAGLView.h
//  HelloShader
//
//  Created by Douglass Turner on 5/3/13.
//  Copyright (c) 2013 Elastic Image Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class GLRenderer;

@interface GLView : UIView {    
	
@private
    id				m_displayLink;
	GLRenderer *m_renderer;
    BOOL			m_animating;
	NSInteger		animationFrameInterval;
	
}

@property(nonatomic,retain)id						displayLink;
@property(nonatomic,retain) GLRenderer *renderer;
@property(nonatomic,assign,getter=isAnimating)BOOL	animating;
@property (nonatomic) NSInteger						animationFrameInterval;

- (void)startAnimation;
- (void)stopAnimation;
- (void)drawView:(id)sender;

@end
