varying vec2 tc;

out vec4 oColor;

void main() {
	float t = length(tc - vec2(0.5, 0.4));
	oColor = vec4(1,1, 1, 1);
	oColor.rgb *= 1 / t * 0.05;
	if (t <= 0.1) oColor.rgb = vec3(1, 1, 1) * 3;
	else oColor.rgb = vec3(0,0,0);
	if (oColor.r < 0.01) oColor.rgb = -1.5 * vec3(1,1,1);
	
}