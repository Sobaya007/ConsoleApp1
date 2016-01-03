#version 400

attribute vec4 mVertex;
varying vec2 tc;

void main() {
	tc = mVertex.xy;
	tc = (tc + vec2(1, 1)) * 0.5;
	gl_Position=vec4(mVertex.xyz, 1.0);
}