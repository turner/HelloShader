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

@interface GLView ()
@property(nonatomic,retain)                    id displayLink;
@property(nonatomic,assign,getter=isAnimating) BOOL animating;
@property (nonatomic) NSInteger animationFrameInterval;
- (id)initializeEAGL;
- (void)drawView:(id)sender;
- (void)startAnimation;
- (void)stopAnimation;
@end

@implementation GLView {

    id _displayLink;
    BOOL _animating;
    NSInteger animationFrameInterval;

}

@synthesize displayLink = _displayLink;
@synthesize animating = _animating;
@synthesize renderer;
@dynamic animationFrameInterval;

- (void)dealloc {

    self.displayLink = nil;
    self.renderer = nil;

    [super dealloc];
}

+ (Class)layerClass {
    return [CAEAGLLayer class];
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
	
	_animating = FALSE;
	animationFrameInterval	= 1;
	_displayLink = nil;
	
	return self;
}

- (void)drawView:(id)sender {
    if (nil != self.renderer) [self.renderer render];
}

- (void)layoutSubviews {

    [self stopAnimation];
    if (nil != self.renderer) [self.renderer resizeFromLayer:(CAEAGLLayer*)self.layer];
	[self startAnimation];
	
    [self drawView:nil];
}

- (NSInteger)animationFrameInterval {
    return animationFrameInterval;
}

- (void)setAnimationFrameInterval:(NSInteger)frameInterval {
	
    if (frameInterval >= 1) {
		
		animationFrameInterval = frameInterval;
		
        if (self.isAnimating) {
            [self stopAnimation];
            [self startAnimation];
        }
    }
}

- (void)startAnimation {

    if (!self.isAnimating) {
		self.displayLink = [NSClassFromString(@"CADisplayLink") displayLinkWithTarget:self selector:@selector(drawView:)];
		[self.displayLink setFrameInterval:animationFrameInterval];
		[self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        self.animating = YES;
    }
	
}

- (void)stopAnimation {
	
    if (self.isAnimating) {
		[self.displayLink invalidate];
		self.displayLink = nil;
        self.animating = NO;
    }
	
}

@end
