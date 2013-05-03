//
//  Shader.fsh
//  HelloiPadGLSL
//
//  Created by turner on 3/23/10.
//  Copyright Douglass Turner Consulting 2010. All rights reserved.
//

varying lowp vec4 colorVarying;

void main()
{
    gl_FragColor = colorVarying;
}
