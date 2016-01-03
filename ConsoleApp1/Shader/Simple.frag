#version 400

out vec4 oColor;
varying vec2 tc;
uniform sampler2D mTexture;

void main() {
	//oColor = vec4(dagger, 1);
	oColor = texture2D(mTexture, tc);
}