#version 400

varying vec2 tc;
out vec4 oColor;
uniform sampler2D mVelocityTexture;

void main() {
	vec2 dep = tc - texture2D(mVelocityTexture, tc).xy;
	oColor = texture2D(mVelocityTexture, dep);
	oColor.y -= 0.00001;
	if (length(tc - vec2(0.5, 0.5)) >= 0.4
	&& tc.y > 0.3) oColor.rg = vec2(0, 0);
	if (tc.y < 0.1) oColor.rg = vec2(0, 0);
	oColor *= 0.9995;
}