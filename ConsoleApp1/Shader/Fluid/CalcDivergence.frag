#version 400

varying vec2 tc;
out vec4 oColor;
uniform sampler2D mTexture; 
uniform float epsilon;

//div = -2~2
void main() {
	vec4 l = texture2D(mTexture, tc + vec2(-epsilon, 0));
	vec4 r = texture2D(mTexture, tc + vec2(+epsilon, 0));
	vec4 b = texture2D(mTexture, tc + vec2(0, -epsilon));
	vec4 t = texture2D(mTexture, tc + vec2(0, +epsilon));
	oColor.r = -l.x + r.x - b.y + t.y;
}