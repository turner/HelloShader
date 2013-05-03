//
//  EAGLView.m
//  HelloiPadGLSL
//
//  Created by turner on 3/23/10.
//  Copyright Douglass Turner Consulting 2010. All rights reserved.
//

#import "EAGLView.h"
#import "ES2Renderer.h"

@interface EAGLView (PrivateMethods)
-(id)initializeEAGL;
@end

@implementation EAGLView

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
	
	NSLog(@"EAGL View - init With Frame: origin(%f %f) size(%f %f)", 
		  frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
	
    if ((self = [super initWithFrame:frame])) {
		
		self = [self initializeEAGL];
		
    } // if ((self = [super initWithFrame:frame]))
	
    return self;
}

- (id)initWithCoder:(NSCoder*)coder {    
	
	NSLog(@"EAGL View - init With Coder");
	
    if ((self = [super initWithCoder:coder])) {
		
		self = [self initializeEAGL];
		
    } // if ((self = [super initWithCoder:coder]))
	
    return self;
}

-(id)initializeEAGL {
	
	NSLog(@"EAGL View - initialize EAGL");
	
	CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
	
	NSLog(@"bounds: %f %f %f %f", eaglLayer.bounds.origin.x, eaglLayer.bounds.origin.y, eaglLayer.bounds.size.width, eaglLayer.bounds.size.height);
	//	NSLog(@"transform");
	//	NSLog(@"%f %f %f %f", eaglLayer.transform.m11, eaglLayer.transform.m12, eaglLayer.transform.m13, eaglLayer.transform.m14);
	//	NSLog(@"%f %f %f %f", eaglLayer.transform.m21, eaglLayer.transform.m22, eaglLayer.transform.m23, eaglLayer.transform.m24);
	//	NSLog(@"%f %f %f %f", eaglLayer.transform.m31, eaglLayer.transform.m32, eaglLayer.transform.m33, eaglLayer.transform.m34);
	//	NSLog(@"%f %f %f %f", eaglLayer.transform.m41, eaglLayer.transform.m42, eaglLayer.transform.m43, eaglLayer.transform.m44);
	
	eaglLayer.opaque = TRUE;
	eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSNumber numberWithBool:FALSE], kEAGLDrawablePropertyRetainedBacking, 
									kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, 
									nil];
	
	self.renderer = [[[ES2Renderer alloc] init] autorelease];
	
	if (nil == self.renderer) {
		
		[self release];
		
		return self.renderer;
		
	} // if (nil == self.renderer)
	
	m_animating				= FALSE;
	animationFrameInterval	= 1;
	m_displayLink			= nil;
	
	return self;
	
}

- (void)drawView:(id)sender {
	
    [self.renderer render];
}

- (void)layoutSubviews {
	
	NSLog(@"EAGL View - layout Subviews");
	
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
	
	NSLog(@"EAGL View - start Animation");
	
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
