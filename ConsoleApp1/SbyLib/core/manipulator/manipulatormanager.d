module sbylib.core.manipulator.manipulatormanager;

import sbylib;

class ManipulatorManager {
	private static Manipulator[] manipulatorList;

	static void MoveAll() {
		foreach (m; manipulatorList) m.Manipulate();
	}

	static void Add(Manipulator manip) {
		manipulatorList ~= manip;
	}
}