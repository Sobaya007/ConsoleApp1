attribute vec4 mVertex;
attribute vec2 mTexcoord;

uniform mat4 mWorld;
uniform mat4 mViewProj;

varying vec2 tc;

void main() {
	gl_Position = mViewProj * mWorld * mVertex;
	tc = mTexcoord;
}