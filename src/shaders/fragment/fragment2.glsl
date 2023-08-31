precision mediump float;

#define PI 3.14159265358979
const int type = 2;
uniform vec2 uResolution;
uniform float uTime;

//original
// void main() {
// 	vec2 p = ( gl_FragCoord.xy / uResolution.xy ) -0.5, pos = p;
//   p.x *= uResolution.x / uResolution.y;
//   float dist = 1.0;
//   float angle = PI;
//   float r = clamp(1.5 * sin(uTime), 1., 2.);
//   vec3 color1 = vec3(1., 0.96, 0.05);
//   vec3 color2 = vec3(0.05);
//   float f2 = r - 1. + sin(uTime * 0.2 +atan(p.x, p.y) * 5.);
//   float f3 = r - 1. + cos(uTime *-0.3 + 5.*length(p)+atan(p.x, p.y) * 5.);

//   float par = 12. * sin(uTime * 0.1);
//   float t = clamp(par, -5., 5.);
//   float f = mix(f2, f3, t);

//   pos = vec2(cos(angle),sin(angle))* r * cos(f + angle);
//   dist = ( 22. / sqrt(dot(pos, pos )));
//   if(type == 0) {
//     color1 *= color2*dist;
//   } else if (type == 1) {
//     color1 *= sqrt(color2*dist/2.);
//   } else if (type == 2) {
//     color1 *= pow(color2 * vec3(dist), vec3(-1.5));
//   } else if (type == 3) {
//     color1 += pow(color2 * dist, vec3(-1.5));
//   } else if (type == 4) {
//     color1 += pow(dist, (-1.0));
//   } else {
//     color1 = (1. - color1)*  dist;
//     color1 *= color2*dist;
//   }
//   color1 = mix(1.-color1, color1,  dot(pos, pos));

//   gl_FragColor = vec4(color1, 1.0);
// }

//change
void main() {
	vec2 p = ( gl_FragCoord.xy / uResolution.xy ) - 0.5, pos = p;
  p.x *= uResolution.x / uResolution.y;
  float dist = 1.0;
  float angle = PI;
  float r = clamp(1.5 * cos(uTime), 1., 2.);
  vec3 color1 = vec3(0.0, 0.2157, 0.0078);
  vec3 color2 = vec3(0.0, 0.0, 0.0);
  float f2 = r - 1. + tan(uTime * 0.7 + atan(p.x, p.y) * 5.);
  float f3 = r - 1. + tan(uTime * -0.3 + 20. * length(p) + atan(p.x, p.y) * 10.);

  float par = 20. * tan(uTime * 0.5);
  float t = clamp(par, -5., 5.);
  float f = mix(f2, f3, t);

  pos = vec2(tan(angle),cos(angle)) * r * sin(f + angle) * 1.9;
  dist = ( 15. / sqrt(dot(pos, pos)));
  if(type == 0) {
    color1 *= color2*dist;
  } else if (type == 1) {
    color1 *= sqrt(color2 * dist / 9.);
  } else if (type == 2) {
    color1 *= pow(color2 * vec3(dist), vec3(-1.5));
  } else if (type == 3) {
    color1 += pow(color2 * dist, vec3(-1.5));
  } else if (type == 4) {
    color1 += pow(dist, (-1.0));
  } else {
    color1 = (1. - color1)*  dist;
    color1 *= color2*dist;
  }
  color1 = mix(10. - color1, color1,  dot(pos, pos));

  gl_FragColor = vec4(color1, 1.0);
}