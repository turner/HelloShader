//
//  EITextureOldSchool.m
//  HelloTexture
//
//  Created by turner on 5/26/09.
//  Copyright 2009 Douglass Turner Consulting. All rights reserved.
//

#import "EITextureOldSchool.h"
#import "EISGLUtils.h"

@interface EITextureOldSchool ()
- (id)initWithTextureFile:(NSString *)name mipmap:(BOOL)mipmap;
@end

@implementation EITextureOldSchool

@synthesize name = _name;
@synthesize glslSampler = _glslSampler;
@synthesize width = _width;
@synthesize height = _height;

- (void)dealloc {
	
	glDeleteTextures(1, &_name);

	[super dealloc];
}

typedef enum {
		NGTextureFormat_Invalid = 0,
		NGTextureFormat_A8,
		NGTextureFormat_LA88,
		NGTextureFormat_RGB_565,
		NGTextureFormat_RGBA_5551,
		NGTextureFormat_RGB_888,
		NGTextureFormat_RGBA_8888,
		NGTextureFormat_RGB_PVR2,
		NGTextureFormat_RGB_PVR4,
		NGTextureFormat_RGBA_PVR2,
		NGTextureFormat_RGBA_PVR4,
} NGTextureFormat;

static int GetGLColor(NGTextureFormat format) {
	
	switch (format) {
		case NGTextureFormat_RGBA_5551:
		case NGTextureFormat_RGB_888:
		case NGTextureFormat_RGBA_8888:
			return GL_RGBA;
		case NGTextureFormat_RGB_565:
			return GL_RGB;
		case NGTextureFormat_A8:
			return GL_ALPHA;
		case NGTextureFormat_LA88:
			return GL_LUMINANCE_ALPHA;
		default:
			return 0;
	}
}

static int GetGLFormat(NGTextureFormat format) {
	
	switch (format) {
		case NGTextureFormat_A8:
		case NGTextureFormat_LA88:
		case NGTextureFormat_RGB_888:
		case NGTextureFormat_RGBA_8888:
			return GL_UNSIGNED_BYTE;
		case NGTextureFormat_RGBA_5551:
			return GL_UNSIGNED_SHORT_5_5_5_1;
		case NGTextureFormat_RGB_565:
			return GL_UNSIGNED_SHORT_5_6_5;
		default:
			return 0;
	}
}

static bool NGIsPowerOfTwo(uint32_t n) {
	return ((n & (n-1)) == 0);
}

const int kMaxTextureSizeExp = 10;
#define kMaxTextureSize (1 << kMaxTextureSizeExp)

static int NextPowerOfTwo(int n) {
	
	if (NGIsPowerOfTwo(n)) return n;
	
	for (int i = kMaxTextureSizeExp - 1; i > 0; i--) {
		
		if (n & (1 << i)) return (1 << (i+1));
		
	}
	
	return kMaxTextureSize;
}

static NGTextureFormat GetImageFormat(CGImageRef image) {
	
	CGImageAlphaInfo alpha = CGImageGetAlphaInfo(image);

	bool hasAlpha = FALSE;
	hasAlpha = (alpha != kCGImageAlphaNone && alpha != kCGImageAlphaNoneSkipLast && alpha != kCGImageAlphaNoneSkipFirst);
	
	CGColorSpaceRef color = CGImageGetColorSpace(image);
	CGColorSpaceModel colorSpaceModel = CGColorSpaceGetModel(color);
	
	int bpp	= CGImageGetBitsPerPixel(image);
	
	if (color != NULL) {
		
		if ( colorSpaceModel == kCGColorSpaceModelMonochrome) {
			
			if (hasAlpha) {
				
				return NGTextureFormat_LA88;
			} else {
				
				return NGTextureFormat_A8;
			}

		}
		
		if (bpp == 16) {
			
			if (hasAlpha) {
				
				return NGTextureFormat_RGBA_5551;
			} else {
				
				return NGTextureFormat_RGB_565;
			}

		}
		
		if (hasAlpha) {
			
			return NGTextureFormat_RGBA_8888;
		} else {
			
			return NGTextureFormat_RGB_888;
		}
		
	}
	
	return NGTextureFormat_A8;
}

static uint8_t *GetImageData(CGImageRef image, NGTextureFormat format) {
	
	CGContextRef	context		= NULL;
	uint8_t*		data		= NULL;
	CGColorSpaceRef	colorSpace	= NULL;
	
	int src_width	= CGImageGetWidth(image);
	int src_height	= CGImageGetHeight(image);
	
	int width	= NextPowerOfTwo(src_width);
	int height	= NextPowerOfTwo(src_height);
	
	int num_channels = 0;
	
	switch (format) {
			
		case NGTextureFormat_RGBA_8888:
			colorSpace = CGColorSpaceCreateDeviceRGB();
			num_channels = 4;
			data = malloc(height * width * num_channels);
			context = CGBitmapContextCreate(data, 
											width, 
											height, 
											8, 
											num_channels * width, 
											colorSpace, 
											kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
			CGColorSpaceRelease(colorSpace);
			break;
			
		case NGTextureFormat_RGB_888:
			colorSpace = CGColorSpaceCreateDeviceRGB();
			num_channels = 4;
			data = malloc(height * width * num_channels);
			context = CGBitmapContextCreate(data, 
											width, 
											height, 
											8, 
											num_channels * width, 
											colorSpace, 
											kCGImageAlphaNoneSkipLast | kCGBitmapByteOrder32Big);
			CGColorSpaceRelease(colorSpace);
			break;
			
		case NGTextureFormat_A8:
			data = malloc(height * width);
			context = CGBitmapContextCreate(data, 
											width, 
											height, 
											8, 
											width, 
											NULL, 
											kCGImageAlphaOnly);
			break;
			
		case NGTextureFormat_LA88:
			colorSpace = CGColorSpaceCreateDeviceRGB();
			data = malloc(height * width * 4);
			context = CGBitmapContextCreate(data, 
											width, 
											height, 
											8, 
											4 * width, 
											colorSpace, 
											kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
			CGColorSpaceRelease(colorSpace);
			break;
			
		default:
			break;
	}
	
	if(context == NULL) {
		return NULL;
	}
	
    CGContextSetBlendMode(context, kCGBlendModeCopy);
	
	// This is needed because Quartz uses an origin at lower left and UIKit uses
	// origin at upper left
	// CGAffineTransformMake(a b c d tx ty)
	//
	//   a  c  tx
	//   b  d  ty
	//
	// To invert the image do this
	//   1   0  0
	//   0  -1  height
	//
	CGAffineTransform flipped = CGAffineTransformMake(1, 0, 0, -1, 0, height);
	CGContextConcatCTM(context, flipped);
	
	CGRect rect =  CGRectMake(0, 0, width, height);
	CGContextDrawImage(context, rect, image);
	
	CGContextRelease(context);
	
	return data;
}

- (id)initWithTextureFile:(NSString *)name mipmap:(BOOL)mipmap {
	
	self = [super init];
	
	if(nil != self) {
				
		NSData *texture_data	= [[[NSData  alloc] initWithContentsOfFile:name] autorelease];
		UIImage *ui_image		= [[[UIImage alloc] initWithData:texture_data] autorelease];
		
		if (ui_image.CGImage != NULL) {
			
			NGTextureFormat format	= GetImageFormat(ui_image.CGImage);
			int glColor				= GetGLColor(format);
			int glFormat			= GetGLFormat(format);
			
			_width = (GLuint)NextPowerOfTwo(CGImageGetWidth(ui_image.CGImage));
			_height = (GLuint)NextPowerOfTwo(CGImageGetHeight(ui_image.CGImage));
			
			uint8_t *data = GetImageData(ui_image.CGImage, format);
			
			glGenTextures(1, &_name);
			glBindTexture(GL_TEXTURE_2D, _name);

			// Wrap at textureTarget boundaries
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
			
			// lerp 4 nearest texels and lerp between pyramid levels.
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
			
			// lerp 4 nearest texels.
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
			
			
			glTexImage2D(GL_TEXTURE_2D, 0, glColor, _width, _height, 0, glColor, glFormat, data);
			
			glGenerateMipmap( GL_TEXTURE_2D );
			
			if(glGetError()) {
				NSLog(@"TEI Texture - init With Texture File - glTexImage2D failed");
			}
			
			free(data);

            glBindTexture(GL_TEXTURE_2D, 0);

		} // if (image != NULL)
		
		
	} // if(nil != self)
	
	return self;
}

- (id)initWithImageFile:(NSString *)name extension:(NSString *)extension mipmap:(BOOL)mipmap {
	
	NSString *fullPath = [[NSBundle mainBundle] pathForResource:name ofType:extension];

	if ([extension isEqualToString:@"jpg"] || [extension isEqualToString:@"png"]) {
		
		return [self initWithTextureFile:fullPath mipmap:mipmap];
	}

	return self;
}

- (id)initFBORenderTextureRGBA8Width:(NSUInteger)width height:(NSUInteger)height {

    self = [super init];

    if(nil != self) {

        self.width  = width;
        self.height = height;

        glGenTextures(1, &_name);
        glBindTexture(GL_TEXTURE_2D, _name);

        // bi-linear interpolation
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        [EISGLUtils checkGLError];

        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        [EISGLUtils checkGLError];

        // clamp to edges
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        [EISGLUtils checkGLError];

        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        [EISGLUtils checkGLError];

        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, self.width, self.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
        [EISGLUtils checkGLError];

        glBindTexture(GL_TEXTURE_2D, 0);

    }

    return self;

}

@end
