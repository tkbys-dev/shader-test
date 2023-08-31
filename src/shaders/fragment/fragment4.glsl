precision mediump float;
const float _Speed = 5.5 * 0.002;
const float _Scale = 0.2;
const float _Gamma = 0.15;
const float _Colour = 0.15;
const float _Brightness = 2.0;
const float _Lacunarity = 1.6;

uniform vec2 uResolution;
uniform float uTime;
uniform sampler2D mainTex;

#ifdef USE_PROCEDURAL

//iq noise fns
float hash( float n ) {
	return fract(sin(n)*43758.5453);
}

float noise( in vec3 x ) {
	vec3 p = floor(x);
	vec3 f = fract(x);

	f = f*f*(3.0-2.0*f);
	float n = p.x + p.y*57.0 + 113.0*p.z;
	return mix(mix(mix( hash(n+  0.0), hash(n+  1.0),f.x),
	mix( hash(n+ 57.0), hash(n+ 58.0),f.x),f.y),
	mix(mix( hash(n+113.0), hash(n+114.0),f.x),
	mix( hash(n+170.0), hash(n+171.0),f.x),f.y),f.z);
}

#else

// hq texture noise
float noise( in vec3 x )
{
    vec3 p = floor(x);
    vec3 f = fract(x);
	f = f*f*(3.0-2.0*f);

	vec2 uv = (p.xy+vec2(37.0,17.0)*p.z);
	vec2 rg1 = texture2D(mainTex, (uv * uTime+ vec2(0.5,0.5))/256.0, -100.0).yx;
	vec2 rg2 = texture2D(mainTex, (uv* uTime+ vec2(1.5,0.5))/256.0, -100.0).yx;
	vec2 rg3 = texture2D(mainTex, (uv* uTime+ vec2(0.5,1.5))/256.0, -100.0).yx;
	vec2 rg4 = texture2D(mainTex, (uv* uTime+ vec2(1.5,1.5))/256.0, -100.0).yx;
	vec2 rg = mix( mix(rg1,rg2,f.x), mix(rg3,rg4,f.x), f.y );

	return mix( rg.x, rg.y, f.z );
}

#endif

//x3
vec3 noise3( in vec3 x) {
	return vec3( noise(x+vec3(123.456,.567,.37)), noise(x+vec3(.11,47.43,19.17)), noise(x) );
}

mat3 rotation(float angle, vec3 axis) {
	float s = sin(-angle);
	float c = cos(-angle);
	float oc = _Colour - c;
	vec3 sa = axis * s;
	vec3 oca = axis * oc;
    return mat3(
    oca.x * axis + vec3(c, -sa.z, sa.y),
    oca.y * axis + vec3(sa.z, c, -sa.x),
    oca.z * axis + vec3(-sa.y, sa.x, c));
}

vec3 fbm(vec3 x, float H, float L) {
	vec3 v = vec3(0);
	float f = 1.;

	for (int i=0; i<7; i++) {
		float w = pow(f,-H);
		v += noise3(x)*w;
		x *= L;
		f *= L;
	}
	return v;
}

void main() {
    vec2 uv = gl_FragCoord.xy / uResolution.xy;
    uv.x *= uResolution.x / uResolution.y;

    // float time = uTime * _Speed;
    float time = _Speed;

    uv *= 1. + 0.25*sin(time * 10.);

    vec3 p = vec3(uv*_Scale,time);

    vec3 axis = 4. * fbm(p, 0.5, _Lacunarity);

    vec3 colorVec = 0.5 * 5. * fbm(p*0.3,0.5,_Lacunarity);

    colorVec = rotation(3.*length(axis),normalize(axis))*colorVec;
    colorVec *= 0.05;

    colorVec = pow(colorVec,vec3(_Gamma));
    gl_FragColor = vec4(_Brightness * colorVec * colorVec,1.0);
}