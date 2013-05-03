//
//  EITexture.m
//  HelloTexture
//
//  Created by turner on 5/26/09.
//  Copyright 2009 Douglass Turner Consulting. All rights reserved.
//

#import "EITexture.h"

static GLubyte checkImage[checkImageHeight][checkImageWidth][4];

@implementation EITexture

@synthesize name = m_name;
@synthesize location = m_location;
@synthesize width = m_width;
@synthesize height = m_height;
@synthesize pvrTextureData = m_pvrTextureData;

- (void)dealloc {
	
    [m_pvrTextureData release], m_pvrTextureData = nil;
	glDeleteTextures(1, &m_name);
	
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

- (id)init {
	
	self = [super init];
	
	if(nil != self) {
		
		m_width	= checkImageWidth;
		m_height	= checkImageHeight;
		
		[self makeCheckImage];
		
		glGenTextures(1, &m_name);
		glBindTexture(GL_TEXTURE_2D, m_name);
		
		// Wrap at texture boundaries
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
		
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
		
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, m_width, m_height, 0, GL_RGBA, GL_UNSIGNED_BYTE, checkImage);
		
		//		glGenerateMipmapOES(GL_TEXTURE_2D);
		
		GLenum err = glGetError();
		if (err != GL_NO_ERROR) {
			NSLog(@"Error Uploading Texture to GPU. glError: 0x%04X", err);
		}
		
		m_pvrTextureData = [[NSMutableArray alloc] init];
		
	}
	
	return self;
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
			
			m_width	= NextPowerOfTwo(CGImageGetWidth(ui_image.CGImage));
			m_height	= NextPowerOfTwo(CGImageGetHeight(ui_image.CGImage));
			
			uint8_t *data = GetImageData(ui_image.CGImage, format);
			
			glGenTextures(1, &m_name);
			glBindTexture(GL_TEXTURE_2D, m_name);

			
			
			// Wrap at texture boundaries
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
			
			// lerp 4 nearest texels and lerp between pyramid levels.
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
			
			// lerp 4 nearest texels.
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
			
			
			glTexImage2D(GL_TEXTURE_2D, 0, glColor, m_width, m_height, 0, glColor, glFormat, data);
			
			glGenerateMipmap( GL_TEXTURE_2D );
			
			if(glGetError()) {
				NSLog(@"TEI Texture - init With Texture File - glTexImage2D failed");
			}
			
			free(data);
			
			
		} // if (image != NULL)
		
		
	} // if(nil != self)
	
	return self;
}

- (id)initWithImageFile:(NSString *)name extension:(NSString *)extension mipmap:(BOOL)mipmap {
	
	NSString *fullPath = [[NSBundle mainBundle] pathForResource:name ofType:extension];

	if ([extension isEqualToString:@"jpg"] || [extension isEqualToString:@"png"]) {
		
		return [self initWithTextureFile:fullPath mipmap:mipmap];
	}
	
	if ([extension isEqualToString:@"pvr"]) {
		
		return [self initWithPVRTextureFile:fullPath mipmap:mipmap];
	}
	
	return self;
}

- (id)initWithPVRTextureFile:(NSString *)path mipmap:(BOOL)mipmap {
	
	self = [super init];
	
	if(self != nil) {
		
		NSData *data = [NSData dataWithContentsOfFile:path];
		
		m_pvrTextureData = [[NSMutableArray alloc] init];
		
		if (!data) {
			
			[self release];
			self = nil;
			return self;
		}
		
		BOOL success = FALSE;
		success = [self ingestPVRTextureFile:data];
		
		if (success == FALSE) {
			
			[self release];
			self = nil;
			return self;
		}
		
	} // if(self != nil)
	
	return self;
}

#define PVR_TEXTURE_FLAG_TYPE_MASK	(0xff)

static char gPVRTexIdentifier[4] = "PVR!";

enum {
	kPVRTextureFlagTypePVRTC_2 = 24,
	kPVRTextureFlagTypePVRTC_4
};

typedef struct m_PVRTexHeader {
	uint32_t headerLength;
	uint32_t height;
	uint32_t width;
	uint32_t numMipmaps;
	uint32_t flags;
	uint32_t dataLength;
	uint32_t bpp;
	uint32_t bitmaskRed;
	uint32_t bitmaskGreen;
	uint32_t bitmaskBlue;
	uint32_t bitmaskAlpha;
	uint32_t pvrTag;
	uint32_t numSurfs;
} PVRTexHeader;

- (BOOL)ingestPVRTextureFile:(NSData *)data {
	
	PVRTexHeader *header = (PVRTexHeader *)[data bytes];
	
	uint32_t pvrTag = CFSwapInt32LittleToHost(header->pvrTag);
	if (gPVRTexIdentifier[0] != ((pvrTag >>  0) & 0xff) ||
		gPVRTexIdentifier[1] != ((pvrTag >>  8) & 0xff) ||
		gPVRTexIdentifier[2] != ((pvrTag >> 16) & 0xff) ||
		gPVRTexIdentifier[3] != ((pvrTag >> 24) & 0xff)) {
		
		return FALSE;
	}
	
	uint32_t flags			= CFSwapInt32LittleToHost(header->flags);
	uint32_t formatFlags	= flags & PVR_TEXTURE_FLAG_TYPE_MASK;
	
	if (formatFlags != kPVRTextureFlagTypePVRTC_4 && formatFlags != kPVRTextureFlagTypePVRTC_2) {
		return FALSE;
	}
	
	[m_pvrTextureData removeAllObjects];
	
	GLenum internalFormat = GL_COMPRESSED_RGBA_PVRTC_4BPPV1_IMG;
	if (     formatFlags == kPVRTextureFlagTypePVRTC_4) internalFormat = GL_COMPRESSED_RGBA_PVRTC_4BPPV1_IMG;
	else if (formatFlags == kPVRTextureFlagTypePVRTC_2) internalFormat = GL_COMPRESSED_RGBA_PVRTC_2BPPV1_IMG;
	
	uint32_t w = 0;
	uint32_t h = 0;
	m_width	= w = CFSwapInt32LittleToHost(header->width);
	m_height	= h = CFSwapInt32LittleToHost(header->height);
	
	BOOL hasAlpha;
	if (CFSwapInt32LittleToHost(header->bitmaskAlpha)) hasAlpha = TRUE;
	else                                               hasAlpha = FALSE;
	
	uint32_t dataLength	= CFSwapInt32LittleToHost(header->dataLength);
	uint32_t dataOffset = 0;
	uint32_t dataSize	= 0;
	
	uint8_t *my_bytes		= ((uint8_t *)[data bytes]) + sizeof(PVRTexHeader);
	
	uint32_t blockSize		= 0;
	uint32_t widthBlocks	= 0;
	uint32_t heightBlocks	= 0;
	uint32_t bits_per_pixel = 4;
	
	// Calculate the data size for each texture level and respect the minimum number of blocks
	while (dataOffset < dataLength) {
		
		if (formatFlags == kPVRTextureFlagTypePVRTC_4) {
			
			blockSize = 4 * 4; // Pixel by pixel block size for 4bpp
			widthBlocks = w / 4;
			heightBlocks = h / 4;
			bits_per_pixel = 4;
		} else {
			
			blockSize = 8 * 4; // Pixel by pixel block size for 2bpp
			widthBlocks = w / 8;
			heightBlocks = h / 4;
			bits_per_pixel = 2;
		}
		
		// Clamp to minimum number of blocks
		if (widthBlocks < 2) widthBlocks	= 2;
		if (heightBlocks < 2) heightBlocks	= 2;
		
		dataSize = widthBlocks * heightBlocks * ((blockSize  * bits_per_pixel) / 8);
		
		[ m_pvrTextureData addObject:[ NSData dataWithBytes:my_bytes + dataOffset length:dataSize ] ];
		
		dataOffset += dataSize;
		
		w	= MAX( w >> 1, 1);
		h	= MAX(h >> 1, 1);
	}
	
	// Create OpenGL texture
	
	
	if ([m_pvrTextureData count] <= 0) {
		return FALSE;
	}
	
	
	if (m_name != 0) {
		glDeleteTextures(1, &m_name);
	}
	
	glGenTextures(1, &m_name);
	glBindTexture(GL_TEXTURE_2D, m_name);
		
//	glTexEnvf(GL_TEXTURE_ENV, 
//			  GL_TEXTURE_ENV_MODE, 
//			  GL_REPLACE);	
	
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
	
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	
	w = m_width;
	h = m_height;
	for (int i = 0; i < [m_pvrTextureData count]; i++) {
		
		NSData *data = [m_pvrTextureData objectAtIndex:i];
		
		GLsizei length = [data length];
		glCompressedTexImage2D(GL_TEXTURE_2D, i, internalFormat, w, h, 0, length, [data bytes]);
		
		GLenum err = glGetError();
		if (err != GL_NO_ERROR) {
			
			NSLog(@"Error uploading compressed texture level: %d. glError: 0x%04X", i, err);
			return FALSE;
		}
		
		w = MAX(w >> 1, 1);
		h = MAX(h >> 1, 1);
	}
	
	[m_pvrTextureData removeAllObjects];
	
	return TRUE;
}

-(void) makeCheckImage {
	
	for (int i = 0; i < m_height; i++) {
		
		for (int j = 0; j < m_width; j++) {
			
			int c = ( ( ( (i & 0x8) == 0) ^ ( (j & 0x8) ) == 0) ) * 255;
			
			checkImage[i][j][0] = (GLubyte) c;
			checkImage[i][j][1] = (GLubyte) c;
			checkImage[i][j][2] = (GLubyte) c;
			checkImage[i][j][3] = (GLubyte) 255;
//			checkImage[i][j][3] = (GLubyte) 128;

		}
	}
}

@end
