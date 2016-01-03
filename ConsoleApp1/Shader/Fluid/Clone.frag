#version 400

varying vec2 tc;
out vec4 oColor;
uniform sampler2D mTexture; 

void main() {
	oColor = texture2D(mTexture, tc);
}