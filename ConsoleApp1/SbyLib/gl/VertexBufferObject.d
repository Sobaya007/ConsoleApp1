module sbylib.gl.VertexBufferObject;

import sbylib;

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
		glBufferData(GL_ARRAY_BUFFER, data.length * T.sizeof, cast(void*)data, usage);
		glBindBuffer(GL_ARRAY_BUFFER, 0);
		length = data.length;
	}

	~this() {
		glDeleteBuffers(1, &id);
	}

	void Bind() {
		glBindBuffer(GL_ARRAY_BUFFER, id);
	}

	void UnBind() {
		glBindBuffer(GL_ARRAY_BUFFER, 0);
	}

	void Update(int S = 0)(T[] data) {
		glBindBuffer(GL_ARRAY_BUFFER, id);
		T* ptr = cast(T*)glMapBuffer(GL_ARRAY_BUFFER, GL_WRITE_ONLY);
		if (ptr) {
			foreach (i; 0..length) {
				ptr[i] = data[i];
			}
		}
		glUnmapBuffer(GL_ARRAY_BUFFER);
		glBindBuffer(GL_ARRAY_BUFFER, 0);
	}

	void Update(int S)(Vector!(T, S)[] vertex) {
		T[] array;
		foreach (v; vertex) array ~= vertex.array;
		Update(array);
	}

	alias id this;
}

alias VertexBufferObject!float VBO;