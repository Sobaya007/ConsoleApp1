module sbylib.gl.VertexBufferObject;

import sbylib.imports;

class VertexBufferObject(T) {

	static enum Frequency {
		STREAM, DYNAMIC, STATIC
	}

	immutable uint id;
	private uint usage;
	immutable int length;

	this(T[] data, Frequency frequency) {
		uint id;
		glGenBuffers(1, &id);
		this.id = id;
		if (frequency == Frequency.STREAM) usage = GL_STREAM_DRAW;
		else if (frequency == Frequency.DYNAMIC) usage = GL_DYNAMIC_DRAW;
		else if (frequency == Frequency.STATIC) usage = GL_STATIC_DRAW;
		glBindBuffer(GL_ARRAY_BUFFER, id);
		glBufferData(GL_ARRAY_BUFFER, data.sizeof, data, usage);
		glBindBuffer(GL_ARRAY_BUFFER, 0);
		length = data.length;
	}

	~this() {
		glDeleteBuffers(1, &id);
	}

	void Update(T[] data) {
		glBindBuffer(GL_ARRAY_BUFFER, id);
		T* ptr = cast(T*)glMapBuffer(GL_ARRAY_BUFFER, GL_WRITE_ONLY);
		if (ptr) {
			foreach (i; 0..length) {
				ptr[i] = data[i];
			}
		}
		glBindBuffer(GL_ARRAY_BUFFER, 0);
	}

	alias id this;
}

alias VertexBufferObject!float VBO;