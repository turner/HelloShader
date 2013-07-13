//
//  GLHelpful.h
//  BeautifulPanoramas
//
//  Created by Douglass Turner on 12/4/10.
//  Copyright 2010 Elastic Image Software LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

// uniform index
enum {
    Uniform_ProjectionViewModel,
    Uniform_ViewModelMatrix,
    Uniform_ModelMatrix,
    Uniform_SurfaceNormalMatrix,
    UniformCount
};

// attribute index
enum {
    Attribute_VertexXYZ,
    Attribute_VertexST
};

#define GLDEBUG(x) \
x; \
{ \
    GLenum e; \
    while( (e=glGetError()) != GL_NO_ERROR) \
    { \
        ALog(@"GL Error. Line %d. File %s. glGetError(%@) for call %s", __LINE__, __FILE__, [EISGLHelpful errorString], #x); \
    } \
}

@interface EIGLUtils : NSObject
+ (void)clearErrors;
+ (void) FBOStatus;
+ (BOOL)error;
+ (NSString *)errorString;

+ (void)checkGLError;
@end
