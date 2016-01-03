varying vec2 tc;

const float epsilon = 0.002;

void main() {
	bool flag = false;
	for (float i = 0; i <= 1; i += 0.1) {
		if (abs(tc.x - i) < epsilon) flag = true;
		if (abs(tc.y - i) < epsilon) flag = true;
	}
	if (flag) gl_FragColor = vec4(0.5, 0.5, 0.5, 1);
	else gl_FragColor = vec4(tc, 1, 1);
}