module sbylib.core.manipulator.manipulator;

import sbylib;

abstract class Manipulator {

	protected Entity entity;

	this(Entity entity) {
		this.entity = entity;
	}

	abstract void Manipulate();
}