varying vec2 tc;
out vec4 oColor;
uniform sampler2D mVelocityTexture;
uniform sampler2D mPressureTexture;
uniform float epsilon;

void main() {
	vec4 v = texture2D(mVelocityTexture, tc);
	float l = texture2D(mPressureTexture, tc - vec2(epsilon, 0)).r;
	float r = texture2D(mPressureTexture, tc + vec2(epsilon, 0)).r;
	float b = texture2D(mPressureTexture, tc - vec2(0, epsilon)).r;
	float t = texture2D(mPressureTexture, tc + vec2(0, epsilon)).r;
	oColor.r = v.r + l * 0.5 - r * 0.5;
	oColor.g = v.g + b * 0.5 - t * 0.5;
}