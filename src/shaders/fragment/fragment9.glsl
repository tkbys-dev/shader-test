precision highp float;

uniform float uTime;
uniform vec2  mouse;
uniform vec2  uResolution;

const float PI = 3.14159265;
const float PI2 = PI*2.0;
const float angle = 60.0;
const float fov = angle * 0.5 * PI / 180.0;
const float EPS = 0.001;

mat2 rot(float a) {
    float c = cos(a), s = sin(a);
    return mat2(c,s,-s,c);
}

float box(vec3 p, float s) {
	p = abs(p) - s;
	return max(max(p.x, p.y), p.z);
}

vec2 pmod(vec2 p, float r) {
	float a = PI/r-atan(p.x, p.y);
	float n = PI2/r;
	a = floor(a/n)*n;
	return p*rot(a);
}

mat3 rot3z(float a) {
    float c = cos(a), s = cos(a);
    return mat3(c,-s,0.,s,c,0.,0.,0.,1.);
}

float fbm(float x) { return sin(x) * sin(2. * x) * sin(4. * x); }

float map(vec3 p){
	p.y  += sin(p.z * 3.) * 1.0;
    vec3 q = p;
    const int iterations = 9;
    q.z = mod(q.z-20.0, 40.0)-20.0;
    q.yx = pmod(q.xy, 20.0)-2.0;
    q.xz = pmod(q.xz, 30.0);


    q.z = mod(q.z-5.0 ,10.0) - 5.0;
    q.x = abs(q.x) - 3.0;
    q.y -= 4.;

    // ifs
    for(int i=1; i<iterations; i++) {
        q = abs(q) - vec3(1.0+sin(uTime)*0.3, 2.0+sin(uTime)*0.2, 1.0 + sin(uTime*float(i) - p.z*0.15 - p.y*0.3)*0.5);
        //q.xy *= rot(float(i)*PI);
        q = abs(q) - vec3(0.0, cos(uTime*0.2)*0.1,0.7+sin(uTime)*0.3);
        q.xz *= rot(float(i)*PI*0.75);
        q.z += 0.3 / dot(q, q);
        //q.xzy = q.zyx;
    }
    //q = dot(q, vec3(0.13)) + q.yzx * vec3(0.6, 0.5, 0.4);
    return box(q, sin(uTime)* 0.01 + 0.8);
}

vec3 getNormal(vec3 p){
    float d = 0.001;
    return normalize(vec3(
        map(p + vec3(  d, 0.0, 0.0)) - map(p + vec3( -d, 0.0, 0.0)),
        map(p + vec3(0.0,   d, 0.0)) - map(p + vec3(0.0,  -d, 0.0)),
        map(p + vec3(0.0, 0.0,   d)) - map(p + vec3(0.0, 0.0,  -d))
    ));
}

vec3 hsv(float h, float s, float v) {
    return ((clamp(abs(fract(h+vec3(0,2,1)/3.)*6.-3.)-1.,0.,1.)-1.)*s+1.)*v;
}

vec3 onRep(vec3 p, float interval) {
  return mod(p, interval) - interval * 0.5;
}

float getShadow( vec3 ro, vec3 rd ) {

    float h = 0.0;
    float c = 0.0;
    float r = 1.0;
    float shadowCoef = 0.5;

    for ( float t = 0.0; t < 50.0; t++ ) {

        h = map( ro + rd * c );

        if ( h < 0.001 ) return shadowCoef;

        r = min( r, h * 16.0 / c );
        c += h;

    }

    return 1.0 - shadowCoef + r * shadowCoef;

}

void main(void){
    vec2 p = (gl_FragCoord.xy - uResolution) / min(uResolution.x, uResolution.y);

    float time3 = uTime * 30.0;
    vec3 cPos  = vec3( 0.0, 2.5 + sin(uTime*2.0), time3 );
    vec3 cDir  = normalize( vec3( 0.0, 0.4*sin(uTime)*cos(uTime*0.3)+ 0.01 * fbm(uTime * PI2 * 0.2), 1.0));
    vec3 cSide = cross( cDir, vec3(0.0, 1.0 ,-0.0 ) );
    vec3 cUp   = cross( cSide, cDir );
    float targetDepth = 1.3;
    vec3 ray = normalize( cSide * p.x + cUp * p.y + cDir * targetDepth ) * rot3z(uTime*0.1);

    vec3 lightDir = vec3(1.0,1.0,-2.0);

    float distance = 00.0;
    float rLen = 0.0;
    vec3  rPos = cPos;
    float ac = 0.0;
    for(int i = 0; i < 128; i++){
        rPos = cPos + ray * rLen;
        distance = map(rPos);
        float d2 = max(abs(distance), 0.04 + 0.3 * (exp(3.0 * sin(uTime))/ exp(3.0)));
        ac += exp(-10. * d2) + exp(-5. *distance);
        rLen += distance;

        if (abs(rLen) < EPS) break;
        // fantom
        // distance = max(abs(distance), 0.02);
        // ac += exp(-distance*3.0);
    }

    vec3 color;
    if(abs(distance) < 0.001){
        vec3 normal = getNormal(rPos);
        float diff = dot(normal, normalize(vec3(1., 1., 1.)));
        float specular = pow(clamp(dot(reflect(normalize(vec3(1., 1., 1.)), normal), ray), 0.0,1.0), 100.);
        color =  vec3(1.0) * mix(diff, specular, 0.8);
    }else{
        color = vec3(0.0);
    }
    //元
    // color +=  hsv(rPos.z *0.003, 1.0, 1.0)* ac*0.008;
    //黒
    // color +=  hsv(rPos.z *0.003, 1.0, 0.)* ac * 0.008;
    //明るめ
    color +=  hsv(rPos.z *0.003, 10.0, 1.0)* ac * 0.008;
    gl_FragColor = vec4(color+ 0.01 * rLen, 1.0);

}