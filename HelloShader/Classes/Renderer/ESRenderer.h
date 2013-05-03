//
//  ESRenderer.h
//  HelloiPhoneiPodTouchPanorama
//
//  Created by turner on 2/25/10.
//  Copyright Douglass Turner Consulting 2010. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import <OpenGLES/EAGL.h>
#import <OpenGLES/EAGLDrawable.h>

@protocol ESRenderer <NSObject>

- (void) setupGLView:(CGSize)size;
- (void) render;
- (BOOL) resizeFromLayer:(CAEAGLLayer *)layer;

@end
