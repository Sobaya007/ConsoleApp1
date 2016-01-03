#version 400

attribute vec4 mVertex;
attribute vec2 mTexcoord;
uniform mat4 mWorld;
uniform mat4 mViewProj;
varying vec2 tc;

void main() {
	tc = mTexcoord;
	if (tc.x == 0 && tc.y == 0) tc = mVertex.xy;
	//tc = (tc + vec2(1, 1)) * 0.5;
	gl_Position = mViewProj * mWorld * mVertex;
}