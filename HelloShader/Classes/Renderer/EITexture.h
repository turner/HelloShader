//
//  EITexture.h
//  HelloTexture
//
//  Created by turner on 5/26/09.
//  Copyright 2009 Douglass Turner Consulting. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#define	checkImageWidth  (64)
#define	checkImageHeight (64)

@interface EITexture : NSObject {
	
	GLuint	m_name;
	GLuint	m_location;
	GLuint	m_width;
	GLuint	m_height;
	
	NSMutableArray *m_pvrTextureData;
	
}

@property(nonatomic,assign)GLuint name;
@property(nonatomic,assign)GLuint location;
@property(nonatomic,assign)GLuint width;
@property(nonatomic,assign)GLuint height;
@property(nonatomic,retain)NSMutableArray *pvrTextureData;

- (id)initWithTextureFile:(NSString *)name mipmap:(BOOL)mipmap;

- (id)initWithPVRTextureFile:(NSString *)path mipmap:(BOOL)mipmap;

- (id)initWithImageFile:(NSString *)name extension:(NSString *)extension mipmap:(BOOL)mipmap;

- (BOOL)ingestPVRTextureFile:(NSData *)data;
- (void) makeCheckImage;

@end
