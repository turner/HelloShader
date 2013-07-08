//
//  EISShowShader.fsh
///

#define kShowS                   (1)
#define kShowT                   (kShowS + 1)
#define kShowST                  (kShowT + 1)

#define kShowFragmentCoordinateX (kShowST + 1)
#define kShowFragmentCoordinateY (kShowFragmentCoordinateX + 1)
#define kShowFragmentCoordinateZ (kShowFragmentCoordinateY + 1)
#define kShowFragmentCoordinateW (kShowFragmentCoordinateZ + 1)
#define kShowFragmentCoordinates (kShowFragmentCoordinateW + 1)

#define kShowWorldCoordinateX (kShowFragmentCoordinates + 1)
#define kShowWorldCoordinateY (kShowWorldCoordinateX + 1)
#define kShowWorldCoordinateZ (kShowWorldCoordinateY + 1)
#define kShowWorldCoordinate  (kShowWorldCoordinateZ + 1)

precision mediump float;

uniform float sRepeat;
uniform float tRepeat;

uniform int show;
uniform float windowWidth;
uniform float windowHeight;

varying	mediump vec4 v_position;
varying	mediump vec2 v_st;

void main() {

	// default color
	gl_FragColor = vec4(0.0,  1.0, 0.0, 1.0);

    float ss = mod(v_st.s * sRepeat, 1.0);
    float tt = mod(v_st.t * tRepeat, 1.0);

    float fx = gl_FragCoord.x/windowWidth;
    float fy = gl_FragCoord.y/windowHeight;

    float xx = abs(v_position.x);
    float yy = abs(v_position.y);
    float zz = abs(v_position.z);

    if      (kShowS                   == show) gl_FragColor = vec4(ss,  0.0, 0.0, 0.75);
    else if (kShowT                   == show) gl_FragColor = vec4(0.0, tt,  0.0, 0.75);
    else if (kShowST                  == show) gl_FragColor = vec4(ss,  tt,  0.0, 0.75);
    else if (kShowFragmentCoordinateX == show) gl_FragColor = vec4(fx,  0.0, 0.0, 0.75);
    else if (kShowFragmentCoordinateY == show) gl_FragColor = vec4(0.0, fy,  0.0, 0.75);
    else if (kShowFragmentCoordinates == show) gl_FragColor = vec4(fx,  fy,  0.0, 0.75);

}

