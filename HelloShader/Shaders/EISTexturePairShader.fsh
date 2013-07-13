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

	// Porter-Duff.
	gl_FragColor = (1.0) * matte_rgba + (1.0 - matte_rgba.a) * hero_rgba;




	// gl_FragColor = matte_rgba + (1.0 - matte_rgba.a) * hero_rgba;

	// // accumulata (sum) alpha
// gl_FragColor.a = matte_rgba.a + hero_rgba.a;
	
}
