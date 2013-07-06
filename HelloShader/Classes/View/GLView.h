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

@interface GLView : UIView
@property(nonatomic, retain) GLRenderer *renderer;
@end
