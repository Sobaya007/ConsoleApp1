uniform sampler2D mTexture;
out vec4 oColor;
varying vec2 tc;

const float epsilon = 1.0 / 512;
const int n = 5;

void main() {
	for (int x = -n; x <= n; x++) {
		for (int y = -n; y <= n; y++) {
			oColor += texture2D(mTexture, tc + vec2(x, y) * epsilon);
		}
	}
	oColor /= (2*n+1) * (2*n+1);
}