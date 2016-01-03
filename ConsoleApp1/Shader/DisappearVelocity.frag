varying vec2 tc;
out vec4 oColor;

const float pi = 3.1415926535;

float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

void main() {
	const float cx = 0.375, cy = 0.5;
	const float strength = 0.00005;
	vec2 t = tc - vec2(0.5, 0.5);
	oColor = vec4(0, 0, 0, 1);

	vec2 v = tc - vec2(cx, cy);
	v /= pow(length(v), 3);
	v = vec2(-v.y, v.x) * strength;
	oColor.rg += v;

	v = tc - vec2(1-cx, cy);
	v /= pow(length(v), 3);
	v = vec2(v.y, -v.x) * strength;
	oColor.rg += v;
}