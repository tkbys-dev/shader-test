precision highp float;

uniform vec2 uResolution;
uniform float uTime;
uniform vec2 mouse;
uniform sampler2D backbuffer;

// #define t uTime
// #define r uResolution
// #define FC gl_FragCoord
// #define o gl_FragColor

const float PI = acos(-1.);

void main(void) {
	vec3 P,Q;
	P.z = uTime;
	float d = 1., a, c;
	for(int i = 0; i < 150; i++){
		c++;
		if(d < 1e-4) break;
		a = 1.;
		d = P.y + 1.;
		for(float j = 1.; j < 10.; j++) Q = ( P + fract(sin(j) * 1e4 ) * PI) * a,Q += sin(Q) * 2.,d += sin(Q.x) * sin(Q.z) / a, a *= 2.;
		P += normalize(vec3((gl_FragCoord.xy * 2. - uResolution) / uResolution.y - vec2(0, 1.), 2.)) * d * .15;
	}
	P.z -= uTime;
	// gl_FragColor += mix(1., 1. - c / 150., exp(-dot(P, P) * .03));
	gl_FragColor += mix(1., 1. * c / 150., exp(dot(P, P) * .01));
	gl_FragColor.a = 1.;
}