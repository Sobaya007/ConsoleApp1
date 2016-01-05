module sbylib.math.utils;

import std.math;
import sbylib.math.imports;

U ToRad(U)(U angle) {
	return angle * PI / 180;
}

U ToDeg(U)(U angle) {
	return angle * 180 / PI;
}

