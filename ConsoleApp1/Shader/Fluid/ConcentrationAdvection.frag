#version 400

varying vec2 tc;
out vec4 oColor;
uniform sampler2D mConcentrationTexture; 
uniform sampler2D mVelocityTexture; 

void main() {
	vec2 dep = tc - texture2D(mVelocityTexture, tc).xy;
	oColor = texture2D(mConcentrationTexture, dep);
	oColor = (oColor + vec4(1, 1, 1, 1) * 0.25) * 0.9995 - vec4(1,1, 1, 1) * 0.25;
}