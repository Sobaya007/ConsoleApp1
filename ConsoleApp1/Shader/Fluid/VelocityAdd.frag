#version 400

varying vec2 tc;
out vec4 oColor;
uniform sampler2D mTexture;
uniform vec2 s;
uniform vec2 e;

void main() {
	vec2 v = normalize(tc - s);
	vec2 v2 = normalize(e - s);
	float t = dot(v, v2);
	float d;
	vec2 vec;
	if (t < 0) {
		vec = tc - s;
	} else if (t > 1) {
		vec = tc - e;
	} else {
		vec = tc - (s + (e-s) * t);
	}
	d = length(vec);
	vec = normalize(vec);
	if (s != e) {
		oColor = texture2D(mTexture, tc);
		oColor = vec4(1, 1, 1, 1);
	} else {
		oColor = texture2D(mTexture, tc);
		oColor = vec4(1, 0, 1, 1);
	}
}