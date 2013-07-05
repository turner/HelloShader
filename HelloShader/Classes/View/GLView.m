//
//  EAGLView.m
//  HelloShader
//
//  Created by Douglass Turner on 5/3/13.
//  Copyright (c) 2013 Elastic Image Software. All rights reserved.
//

#import "GLView.h"
#import "GLRenderer.h"
#import "Logging.h"
#import "EISRendererHelper.h"

@interface GLView (PrivateMethods)
-(id)initializeEAGL;
@end

@implementation GLView

@synthesize displayLink = m_displayLink;
@synthesize renderer = m_renderer;
@synthesize animating = m_animating;

@dynamic animationFrameInterval;

- (void)dealloc {
	
    [m_displayLink	release], m_displayLink	= nil;
    [m_renderer		release], m_renderer	= nil;
	
    [super dealloc];
}

-(id)initWithFrame:(CGRect)frame {

    self = [super initWithFrame:frame];

    if (nil != self) {
		
		self = [self initializeEAGL];
    }
	
    return self;
}

- (id)initWithCoder:(NSCoder*)coder {

    self = [super initWithCoder:coder];

    if (nil != self) {

        self = [self initializeEAGL];
    }

    return self;
}

-(id)initializeEAGL {

    CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;

	eaglLayer.opaque = TRUE;
	eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSNumber numberWithBool:FALSE], kEAGLDrawablePropertyRetainedBacking, 
									kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, 
									nil];

    self.renderer = [[[GLRenderer alloc] initWithContext:[[[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2] autorelease]
                                            renderHelper:[[[EISRendererHelper alloc] init] autorelease]] autorelease];

    if (nil == self.renderer) {
		
//		[self release];
//		return self.renderer;

        return nil;
	}
	
	m_animating				= FALSE;
	animationFrameInterval	= 1;
	m_displayLink			= nil;
	
	return self;
}

- (void)drawView:(id)sender {
	
    [self.renderer render];
}

- (void)layoutSubviews {

    [self stopAnimation];
    [self.renderer resizeFromLayer:(CAEAGLLayer*)self.layer];
	[self startAnimation];
	
    [self drawView:nil];
}

- (NSInteger)animationFrameInterval {
	
    return animationFrameInterval;
}

- (void)setAnimationFrameInterval:(NSInteger)frameInterval {
	
    // Frame interval defines how many display frames must pass between each time the
    // display link fires. The display link will only fire 30 times a second when the
    // frame internal is two on a display that refreshes 60 times a second. The default
    // frame interval setting of one will fire 60 times a second when the display refreshes
    // at 60 times a second. A frame interval setting of less than one results in undefined
    // behavior.
    if (frameInterval >= 1) {
		
		animationFrameInterval = frameInterval;
		
        if (self.isAnimating) {
			
            [self stopAnimation];
            [self startAnimation];
			
        } // if (self.isAnimating)
		
    } // if (frameInterval >= 1)
}

- (void)startAnimation {

    ALog(@"");

    if (!self.isAnimating) {
		
		self.displayLink = [NSClassFromString(@"CADisplayLink") displayLinkWithTarget:self selector:@selector(drawView:)];
		[self.displayLink setFrameInterval:animationFrameInterval];
		[self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
			
        self.animating = YES;
		
    }  // if (!self.isAnimating)
	
}

- (void)stopAnimation {
	
    if (self.isAnimating) {
		
		[self.displayLink invalidate];
		self.displayLink = nil;

        self.animating = NO;
		
    } // if (self.isAnimating)
	
}

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

@end
