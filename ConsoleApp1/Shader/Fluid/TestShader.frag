#version 400

out vec4 oColor;
varying vec2 tc;
uniform sampler2D mTexture;

void main() {
	oColor = 1 - clamp(texture2D(mTexture, tc) * 2 + 0.5, 0, 1);
	oColor = texture2D(mTexture, tc);
}