//
//  EIViewController.h
//  HelloShader
//
//  Created by Douglass Turner on 5/3/13.
//  Copyright (c) 2013 Elastic Image Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EIRenderer;

@interface EIViewController : UIViewController
@property(nonatomic, retain) EIRenderer *renderer;
@end
