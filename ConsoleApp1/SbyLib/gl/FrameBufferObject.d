module sbylib.gl.FrameBufferObject;

import sbylib;

class FrameBufferObject {

	alias id this;

	immutable uint id;

	private int[4] viewportData; //writeBeginのときの一時保存用
	private int frameBufferData;
	private int texIdData;

	this() {
		uint id;
		glGenFramebuffers(1, &id);
		this.id = id;
	}

	~this() {
		glDeleteBuffers(1, &id);
	}

	int fb;

	void Bind() {
		int fb;
		glGetIntegerv(GL_FRAMEBUFFER_BINDING, &fb);
		if (fb != id) this.fb = fb;
		glBindFramebuffer(GL_FRAMEBUFFER, id);
	}

	void UnBind() {
		glBindFramebuffer(GL_FRAMEBUFFER, fb);
	}

	void AttachTextureAsColor(TextureObject tex) {
		Bind();
		if (tex)
			glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, tex.texID, 0);
		else
			glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, 0, 0);
		UnBind();
	}

	void AttachTextureAsDepth(TextureObject tex) {
		Bind();
		if (tex)
			glFramebufferTexture2DEXT(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_TEXTURE_2D, tex.texID, 0);
		else
			glFramebufferTexture2DEXT(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_TEXTURE_2D, 0, 0);
		UnBind();
	}

	void AttachRenderBufferObjectAsColor(RenderBufferObject rb) {
		Bind();
		if (rb)
			glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, rb.id);
		else
			glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, 0);
		UnBind();
	}

	void AttachRenderBufferObjectAsDepth(RenderBufferObject rb) {
		Bind();
		if (rb)
			glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, rb.id);
		else
			glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, 0);
		UnBind();
	}

	void WriteBegin(int width, int height) {
		glGetIntegerv(GL_FRAMEBUFFER_BINDING, &frameBufferData);
		Bind();
		// "renderedTexture"を#0に結び付けられている色としてセットする
		glGetIntegerv(GL_FRAMEBUFFER_ATTACHMENT_TEXTURE_LAYER, &texIdData);

		// 描画バッファのリストをセットする
		uint DrawBuffers = GL_COLOR_ATTACHMENT0;

		glDrawBuffers(1, &DrawBuffers); // 1はDrawBufffersのサイズ

		glGetIntegerv(GL_VIEWPORT, viewportData.ptr);
		glViewport(0, 0, width, height);
	}

	void WriteEnd() {
		glBindFramebuffer(GL_FRAMEBUFFER, frameBufferData);
		glFramebufferTexture(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, texIdData, 0);
		glViewport(viewportData[0], viewportData[1], viewportData[2], viewportData[3]);
		UnBind();
	}

	void Write(int width, int height, void delegate() Draw) {
		WriteBegin(width, height);
		Draw();
		WriteEnd();
	}
}