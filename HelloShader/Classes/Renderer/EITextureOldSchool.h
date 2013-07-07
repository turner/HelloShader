//
//  EITextureOldSchool.h
//  HelloTexture
//
//  Created by turner on 5/26/09.
//  Copyright 2009 Douglass Turner Consulting. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@interface EITextureOldSchool : NSObject

- (id)initWithTextureFile:(NSString *)name mipmap:(BOOL)mipmap;
- (id)initWithImageFile:(NSString *)name extension:(NSString *)extension mipmap:(BOOL)mipmap;
- (id)initFBORenderTextureRGBA8Width:(NSUInteger)width height:(NSUInteger)height;

@property(nonatomic,assign)GLuint name;
@property(nonatomic,assign)GLuint glslSampler;
@property(nonatomic,assign)GLuint width;
@property(nonatomic,assign)GLuint height;

@end
