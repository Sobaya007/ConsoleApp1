module sbylib.fpscounter;

import sbylib.imports;

class FpsCounter(uint N) {
	long[N] periods;

	int total;
	StopWatch sw;
	int c;

	this() {
		sw.start();
	}

	void Update() {
		auto p = periods[c];
		periods[c] = sw.peek().msecs();
		total += cast(int)(periods[c] - p);
		c = (c+1)%N;
		sw.reset();
	}

	long GetFPS() {
		if (total == 0) return 0;
		return 1000 * N / total;
	}
}
