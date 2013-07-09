//
//  Created by turner on 4/28/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "EIQuad.h"
#import "Logging.h"

@interface EIQuad ()
- (void)createWithHalfSize:(CGSize)aHalfSize;
@end

@implementation EIQuad

@synthesize halfSize;
@synthesize vertices;

- (void)dealloc {

    free(self.vertices);

	[super dealloc];
}

- (id)initWithHalfSize:(CGSize)aHalfSize {

	self = [super init];
	if (nil != self) {

        self.halfSize = aHalfSize;
        [self createWithHalfSize:self.halfSize];
	}

	return self;
}

- (void)createWithHalfSize:(CGSize)aHalfSize {

    self.vertices = (float *)malloc(4 * 3 * sizeof(float));

    GLfloat *template = [EISRendererHelper verticesXYZ_Template];
    for(NSInteger i = 0; i < 12; i++) self.vertices[i] = template[i];

   	// setup vertices of fboTexture surface
   	NSUInteger stride = 3;
   	NSUInteger xOffset = 0;
   	NSUInteger yOffset = 1;
   	NSUInteger step;


   	// southwest vertex
   	step = 0;
    self.vertices[ step * stride + xOffset] *= aHalfSize.width;
    self.vertices[ step * stride + yOffset] *= aHalfSize.height;

   	// southeast vertex
   	step = 1;
    self.vertices[ step * stride + xOffset] *= aHalfSize.width;
    self.vertices[ step * stride + yOffset] *= aHalfSize.height;

   	// northwest vertex
   	step = 2;
    self.vertices[ step * stride + xOffset] *= aHalfSize.width;
    self.vertices[ step * stride + yOffset] *= aHalfSize.height;

   	// northeast vertex
   	step = 3;
    self.vertices[ step * stride + xOffset] *= aHalfSize.width;
    self.vertices[ step * stride + yOffset] *= aHalfSize.height;

}

@end



