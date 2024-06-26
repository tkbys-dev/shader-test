precision mediump float;

#define PI 3.141592653589793
#define TAU 6.283185307179586
#define pow2(x) (x * x)

uniform vec2 uResolution;
uniform float uTime;
uniform sampler2D tex0;
uniform vec4 whirls[10];

varying vec2 vTexCoord;

const int samples = 8;
const float sigma = float(samples) * 0.25;

float gaussian(vec2 i) {
  return 1.0 / (2.0 * PI * pow2(sigma)) * exp(-((pow2(i.x) + pow2(i.y)) / (2.0 * pow2(sigma))));
}

vec3 blur(sampler2D sp, vec2 uv, vec2 scale) {
  vec3 col = vec3(0.0);
  float accum = 0.0;
  float weight;
  vec2 offset;

  for (int x = -samples / 2; x < samples / 2; ++x) {
    for (int y = -samples / 2; y < samples / 2; ++y) {
      offset = vec2(x, y);
      weight = gaussian(offset);
      col += texture2D(sp, uv + scale * offset).rgb * weight;
      accum += weight;
    }
  }

  return col / accum;
}


float rand(vec2 c){
  return fract(sin(dot(c.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

vec4 permute(vec4 x){return mod(((x*34.0)+1.0)*x, 289.0);}
vec4 taylorInvSqrt(vec4 r){return 1.79284291400159 - 0.85373472095314 * r;}
vec3 fade(vec3 t) {return t*t*t*(t*(t*6.0-15.0)+10.0);}

float cnoise(vec3 P){
  vec3 Pi0 = floor(P);
  vec3 Pi1 = Pi0 + vec3(1.0);
  Pi0 = mod(Pi0, 289.0);
  Pi1 = mod(Pi1, 289.0);
  vec3 Pf0 = fract(P);
  vec3 Pf1 = Pf0 - vec3(1.0);
  vec4 ix = vec4(Pi0.x, Pi1.x, Pi0.x, Pi1.x);
  vec4 iy = vec4(Pi0.yy, Pi1.yy);
  vec4 iz0 = Pi0.zzzz;
  vec4 iz1 = Pi1.zzzz;

  vec4 ixy = permute(permute(ix) + iy);
  vec4 ixy0 = permute(ixy + iz0);
  vec4 ixy1 = permute(ixy + iz1);

  vec4 gx0 = ixy0 / 7.0;
  vec4 gy0 = fract(floor(gx0) / 7.0) - 0.5;
  gx0 = fract(gx0);
  vec4 gz0 = vec4(0.5) - abs(gx0) - abs(gy0);
  vec4 sz0 = step(gz0, vec4(0.0));
  gx0 -= sz0 * (step(0.0, gx0) - 0.5);
  gy0 -= sz0 * (step(0.0, gy0) - 0.5);

  vec4 gx1 = ixy1 / 7.0;
  vec4 gy1 = fract(floor(gx1) / 7.0) - 0.5;
  gx1 = fract(gx1);
  vec4 gz1 = vec4(0.5) - abs(gx1) - abs(gy1);
  vec4 sz1 = step(gz1, vec4(0.0));
  gx1 -= sz1 * (step(0.0, gx1) - 0.5);
  gy1 -= sz1 * (step(0.0, gy1) - 0.5);

  vec3 g000 = vec3(gx0.x,gy0.x,gz0.x);
  vec3 g100 = vec3(gx0.y,gy0.y,gz0.y);
  vec3 g010 = vec3(gx0.z,gy0.z,gz0.z);
  vec3 g110 = vec3(gx0.w,gy0.w,gz0.w);
  vec3 g001 = vec3(gx1.x,gy1.x,gz1.x);
  vec3 g101 = vec3(gx1.y,gy1.y,gz1.y);
  vec3 g011 = vec3(gx1.z,gy1.z,gz1.z);
  vec3 g111 = vec3(gx1.w,gy1.w,gz1.w);

  vec4 norm0 = taylorInvSqrt(vec4(dot(g000, g000), dot(g010, g010), dot(g100, g100), dot(g110, g110)));
  g000 *= norm0.x;
  g010 *= norm0.y;
  g100 *= norm0.z;
  g110 *= norm0.w;
  vec4 norm1 = taylorInvSqrt(vec4(dot(g001, g001), dot(g011, g011), dot(g101, g101), dot(g111, g111)));
  g001 *= norm1.x;
  g011 *= norm1.y;
  g101 *= norm1.z;
  g111 *= norm1.w;

  float n000 = dot(g000, Pf0);
  float n100 = dot(g100, vec3(Pf1.x, Pf0.yz));
  float n010 = dot(g010, vec3(Pf0.x, Pf1.y, Pf0.z));
  float n110 = dot(g110, vec3(Pf1.xy, Pf0.z));
  float n001 = dot(g001, vec3(Pf0.xy, Pf1.z));
  float n101 = dot(g101, vec3(Pf1.x, Pf0.y, Pf1.z));
  float n011 = dot(g011, vec3(Pf0.x, Pf1.yz));
  float n111 = dot(g111, Pf1);

  vec3 fade_xyz = fade(Pf0);
  vec4 n_z = mix(vec4(n000, n100, n010, n110), vec4(n001, n101, n011, n111), fade_xyz.z);
  vec2 n_yz = mix(n_z.xy, n_z.zw, fade_xyz.y);
  float n_xyz = mix(n_yz.x, n_yz.y, fade_xyz.x);
  return 2.2 * n_xyz;
}


void main(){
  vec2 st = vTexCoord;
  st.x *=uResolution.x/uResolution.y;
  st.y= 1.-st.y;

  for(int i=0;i<10;i++){
    // vec2 delta = st-whirls[i].xy;
    vec2 delta = st-whirls[i].xy;
    float d = length(delta);
    float ang = atan(delta.y,delta.x);

    float dr = (1.-smoothstep(0.,whirls[i].w,d))*(-1.+sin(d*5.+uTime+float(i)))*(0.5+cos(d*40.+uTime+float(i)))/2.;
    d+=dr;

    ang+=cnoise(vec3(st*5.,uTime/200.))/30.;

    d+=sin(ang*2.)/5.;

    float dAng = (1.-smoothstep(0.,whirls[i].w,d))*( (10.) *whirls[i].z)/2. ;
    ang += dAng;

    vec2 np = whirls[i].xy + d*vec2(cos(ang),sin(ang));

    st = np;
  }

  st+=cnoise(vec3(st*1.,0.));

  vec2 f_st = fract(st*1.);
  vec2 i_st = floor(st*1.);

  vec3 color = vec3(sin(st.x*1.),sin(st.x*1.5),sin(st.x*2.));

  gl_FragColor= vec4(color,1.0);
}