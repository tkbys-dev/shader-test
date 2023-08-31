precision mediump float;
attribute vec3 aPosition;
attribute vec2 uv;
varying vec2 vTexCoord;

void main() {
  vTexCoord = uv;

  // vec3 resultPosition = vec3(position.x, position.y, position.z);
  // gl_Position = vec4(resultPosition, 1.0);
  vec4 positionVec4 = vec4(aPosition, 1.0);
  positionVec4.xy = positionVec4.xy * 2.0 - vec2(1.0);
  gl_Position = positionVec4;
}