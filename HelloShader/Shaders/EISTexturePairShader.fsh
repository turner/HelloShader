//
//  EISOverShader.fsh
//
precision highp float;

varying	mediump vec2 v_st;

uniform sampler2D hero;
uniform sampler2D matte;

void main() {

	vec4  hero_rgba = texture2D(hero,  v_st);	
	vec4 matte_rgba = texture2D(matte, v_st);


	gl_FragColor.r = matte_rgba.r + (1.0 - matte_rgba.a) * hero_rgba.r;
	gl_FragColor.g = matte_rgba.g + (1.0 - matte_rgba.a) * hero_rgba.g;
	gl_FragColor.b = matte_rgba.b + (1.0 - matte_rgba.a) * hero_rgba.b;
	gl_FragColor.a = matte_rgba.a + (1.0 - matte_rgba.a) * hero_rgba.a;

	
}
