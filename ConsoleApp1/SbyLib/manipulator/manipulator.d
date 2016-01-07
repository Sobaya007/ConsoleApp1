module sbylib.core.manipulator.manipulator;

import sbylib.imports;

abstract class Manipulator {

	protected Entity entity;

	this(Entity entity) {
		this.entity = entity;
	}

	abstract void Manipulate();
}