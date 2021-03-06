module sbylib.gl.RenderBufferObject;

import sbylib;

class RenderBufferObject {
	immutable uint id;

	this() {
		uint id;
		glGenRenderbuffers(1, &id);
		this.id = id;
	}

	~this() {
		glDeleteRenderbuffers(1, &id);
	}

	void Bind() {
		glBindRenderbuffer(GL_RENDERBUFFER, id);
	}

	void UnBind() {
		glBindRenderbuffer(GL_RENDERBUFFER, 0);
	}
}