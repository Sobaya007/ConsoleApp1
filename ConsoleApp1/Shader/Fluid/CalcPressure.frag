#version 400

varying vec2 tc;
out vec4 oColor;
uniform sampler2D mDivergenceTexture;
uniform sampler2D mPressureTexture;
uniform float epsilon;

//pressure = -0.5 ~ 0.5
void main() {
	float l = texture2D(mPressureTexture, tc + vec2(-epsilon, 0)).r;// - 0.5;
	float r = texture2D(mPressureTexture, tc + vec2(+epsilon, 0)).r;// - 0.5;
	float b = texture2D(mPressureTexture, tc + vec2(0, -epsilon)).r;// - 0.5;
	float t = texture2D(mPressureTexture, tc + vec2(0, +epsilon)).r;// - 0.5;
	if (length(tc  + vec2(epsilon, 0)- vec2(0.5, 0.3)) >= 0.6
	&& tc.y > 0.3) oColor.r = texture2D(mPressureTexture, tc).r;
	if (length(tc  + vec2(-epsilon, 0)- vec2(0.5, 0.3)) >= 0.6
	&& tc.y > 0.3) oColor.r = texture2D(mPressureTexture, tc).r;
	if (length(tc  + vec2(0, epsilon)- vec2(0.5, 0.3)) >= 0.6
	&& tc.y > 0.3) oColor.r = texture2D(mPressureTexture, tc).r;
	if (length(tc  + vec2(0, -epsilon)- vec2(0.5, 0.3)) >= 0.6
	&& tc.y > 0.3) oColor.r = texture2D(mPressureTexture, tc).r;
	if (tc.y - epsilon < 0.1) oColor.r = texture2D(mPressureTexture, tc).r;
	float d = texture2D(mDivergenceTexture, tc).r;
	oColor.r = (l + r + b + t - d) / 4;
}