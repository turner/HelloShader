//
//  Created by turner on 4/28/12.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import <Foundation/Foundation.h>
#import "EIRendererHelper.h"

@interface EIQuad : NSObject
- (id)initWithHalfSize:(CGSize)aHalfSize;
@property(nonatomic, assign) CGSize halfSize;
@property(nonatomic, assign) float *vertices;
@end