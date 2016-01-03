#version 400

varying vec2 tc;
out vec4 oColor;


float distBox(vec3 p, vec3 s) {	
	return length(max(vec3(0, 0, 0), abs(p) - s));
}

float distHomo(vec3 p) {
	const float R = 30;
	const float r = 10;
	p.y = -p.y;
	const float depth = 5;
	const float c = cos(45);
	const float s = sin(45);
	float r1 = distBox(p+vec3(25, 0, 0), vec3(2.5, 35, depth));
	float r2 = distBox(p+vec3(25, 20, 0), vec3(17, 2.5, depth));
	float nx = p.x * c - p.y * s;
	float ny = p.x * s + p.y * c;
	float r3 = distBox(vec3(nx+30, ny+30, p.z), vec3(9, 2.5, depth));
	nx = p.x * c + p.y * s;
	ny =-p.x * s + p.y * c;
	float r4 = distBox(vec3(nx, ny-15, p.z), vec3(9, 2.5, depth));
	float r5 = distBox(p + vec3(-25, 0, 0), vec3(2.5, 25, depth));
	float r6 = distBox(p + vec3(-25, 23, 0), vec3(12, 2.5, depth));
	float r7 = distBox(p + vec3(-25, 0, 0), vec3(17, 2.5, depth));
	float r8 = distBox(p + vec3(-33, -23, 0), vec3(10, 2.5, depth));
	return min(r1, min(r2, min(r3, min(r4, min(r5, min(r6, min(r7, r8)))))));
}

void main() {
	vec2 t = tc - vec2(1, 1) * 0.5;
	if (t.x * t.y > 0) {
		oColor.r = 1;
	} else {
		oColor.r = 0;
	}
	t *= 100;
	if (distHomo(vec3(t, 0)) < 0.001)
		oColor.r = 1;
	else
		oColor.r = 0;
}