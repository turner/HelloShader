//
//  EISGaussianBlurEastWest.fsh
//
precision highp float;

varying	mediump vec2 v_st;

uniform int heroChannels;
uniform float heroWidth;
uniform float heroHeight;

uniform sampler2D hero;

float offset[5];
float weight[5];

void main() {

    offset[0] = 0.0; weight[0] = 0.2270270270;
    offset[1] = 1.0; weight[1] = 0.1945945946;
    offset[2] = 2.0; weight[2] = 0.1216216216;
    offset[3] = 3.0; weight[3] = 0.0540540541;
    offset[4] = 4.0; weight[4] = 0.0162162162;
	
	float dev_nullf;
	dev_nullf = heroWidth;
	dev_nullf = heroHeight;

    vec4 raw = (heroChannels == 1) ? vec4(texture2D(hero, v_st).a) : texture2D(hero, v_st);

	vec3 rgb;
	
    rgb = (heroChannels == 1) ? vec3(texture2D(hero, v_st).a) : texture2D(hero, v_st).rgb;
     
    rgb *= weight[0];
		
	vec2 st;	

    for (int i = 1; i < 5; i++) {

        st = v_st + vec2(offset[i]/heroWidth, 0.0);
		rgb += texture2D(hero, st).rgb * weight[i];
		
        st = v_st - vec2(offset[i]/heroWidth, 0.0);
		rgb += texture2D(hero, st).rgb * weight[i];
    }
		
	gl_FragColor = vec4(rgb, raw.a);
	
}
