//
//  EISShowShader.vsh
//

precision mediump float;

uniform mat4 projectionViewModelMatrix;

attribute mediump vec4 position;
attribute mediump vec2 st;

varying	mediump vec4 v_position;
varying	mediump vec2 v_st;

void main() {

    v_position = position;
    v_st = st;

    gl_Position = projectionViewModelMatrix * position;
}
