module SbyFluidUtils;

import Import;

class Fluid(T) {

private:
	FrameBufferObject textureRenderFrameBuffer;
	public TextureObject tex;
	VertexArrayObject!T vao;
	ShaderProgram copy, dCalc, pCalc, cAdv, vAdv, vUpd, gaussian, vAdd;

public:
	TextureObject colorTexture, velocityTexture, divergenceTexture, pressureTexture;

	immutable int size;

	this(ShaderProgram colorInitFragmentShader, ShaderProgram velocityInitFragmentShader, int size) {
		this.size = size;
		const float epsilon = 1.0 / size;
		auto position = [
			-1.0f, -1.0f, 0.5f, 1,
			1.0f, -1.0f, 0.5f, 1,
			-1.0f, 1.0f, 0.5f, 1,
			1.0f, 1.0f, 0.5f, 1,
		];

		vao = new VertexArrayObject!T(4);
		StaticSendBufferData(vao.vertex, position);
		vao.mode = GL_TRIANGLE_STRIP;

		textureRenderFrameBuffer = new FrameBufferObject;
//		int frameBufData;
//		glGetIntegerv(GL_FRAMEBUFFER_BINDING, &frameBufData);
		textureRenderFrameBuffer.Bind();
		tex = new TextureObject(size, size, GL_RGB32F);
		colorTexture = new TextureObject(size, size, GL_RGB32F);
		textureRenderFrameBuffer.AttatchTextureAsColor(colorTexture);
		textureRenderFrameBuffer.Write(size, size, (){
			vao.shaderProgram = colorInitFragmentShader;
			vao.UpdateVertex();
			vao.Draw();
		});

		velocityTexture = new TextureObject(size, size, GL_RG32F);
		textureRenderFrameBuffer.AttatchTextureAsColor(velocityTexture);
		textureRenderFrameBuffer.Write(size, size, (){
			vao.shaderProgram = velocityInitFragmentShader;
			vao.UpdateVertex();
			vao.Draw();
		});

		divergenceTexture = new TextureObject(size, size, GL_R32F);

		pressureTexture = new TextureObject(size, size, GL_R32F);

		copy = new ShaderProgram("Shader/Fluid/TestShader.vert", "Shader/Fluid/Clone.frag", ShaderProgram.InputType.FilePath);
		copy.SetVertex(vao.vertex, null);
		gaussian = new ShaderProgram("Shader/Fluid/TestShader.vert", "Shader/Fluid/Gaussian.frag", ShaderProgram.InputType.FilePath);
		gaussian.SetVertex(vao.vertex, null);
		dCalc = new ShaderProgram("Shader/Fluid/TestShader.vert", "Shader/Fluid/CalcDivergence.frag", ShaderProgram.InputType.FilePath);
		dCalc.SetVertex(vao.vertex, null);
		dCalc.SetTexture(velocityTexture.texID);
		dCalc.SetUniform!(1, "epsilon")(epsilon);
		pCalc = new ShaderProgram("Shader/Fluid/TestShader.vert", "Shader/Fluid/CalcPressure.frag", ShaderProgram.InputType.FilePath);
		pCalc.SetVertex(vao.vertex, null);
		pCalc.SetTexture(divergenceTexture.texID, "mDivergenceTexture");
		pCalc.SetUniform!(1, "epsilon")(epsilon);
		vUpd = new ShaderProgram("Shader/Fluid/TestShader.vert", "Shader/Fluid/VelocityUpdate.frag", ShaderProgram.InputType.FilePath);
		vUpd.SetVertex(vao.vertex, null);
		vUpd.SetTexture(pressureTexture.texID, "mPressureTexture");
		vUpd.SetTexture(tex.texID, "mVelocityTexture", 1);
		vUpd.SetUniform!(1, "epsilon")(epsilon);
		cAdv = new ShaderProgram("Shader/Fluid/TestShader.vert", "Shader/Fluid/ConcentrationAdvection.frag", ShaderProgram.InputType.FilePath);
		cAdv.SetVertex(vao.vertex, null);
		cAdv.SetTexture(tex.texID, "mConcentrationTexture");
		cAdv.SetTexture(velocityTexture.texID, "mVelocityTexture", 1);
		vAdv = new ShaderProgram("Shader/Fluid/TestShader.vert", "Shader/Fluid/VelocityAdvection.frag", ShaderProgram.InputType.FilePath);
		vAdv.SetVertex(vao.vertex, null);
		vAdv.SetTexture(tex.texID, "mVelocityTexture");
		vAdd = new ShaderProgram("Shader/Fluid/TestShader.vert", "Shader/Fluid/VelocityAdd.frag", ShaderProgram.InputType.FilePath);
		vAdd.SetVertex(vao.vertex, null);
		vAdd.SetTexture(tex.texID);

		//ぼかし
		foreach (i; 0..0) {
			textureRenderFrameBuffer.AttatchTextureAsColor(tex);
			textureRenderFrameBuffer.Write(size, size, (){
				Copy(velocityTexture);
			});

			textureRenderFrameBuffer.AttatchTextureAsColor(velocityTexture);
			textureRenderFrameBuffer.Write(size, size, (){
				gaussian.SetTexture(tex.texID);
				vao.shaderProgram = gaussian;
				vao.Draw();
			});
		}

		textureRenderFrameBuffer.UnBind();
	}

	this(string colorInitFragmentPath, string velocityInitFragmentPath, int size) {
		this(new ShaderProgram("Shader/Fluid/TestShader.vert", colorInitFragmentPath, ShaderProgram.InputType.FilePath),
			 new ShaderProgram("Shader/Fluid/TestShader.vert", velocityInitFragmentPath, ShaderProgram.InputType.FilePath),
			 size);
	}

	this(ShaderProgram colorInitFragmentShader, string velocityInitFragmentPath, int size) {
		this(colorInitFragmentShader,
			 new ShaderProgram("Shader/Fluid/TestShader.vert", velocityInitFragmentPath, ShaderProgram.InputType.FilePath),
			 size);
	}

	this(string colorInitFragmentPath, ShaderProgram velocityInitFragmentShader, int size) {
		this(new ShaderProgram("Shader/Fluid/TestShader.vert", colorInitFragmentPath, ShaderProgram.InputType.FilePath),
			 velocityInitFragmentShader,
			 size);
	}

	void Update() {
		with (textureRenderFrameBuffer) {
			textureRenderFrameBuffer.Bind();
			AttatchTextureAsColor(divergenceTexture);
			Write(size, size, () {
				vao.shaderProgram = dCalc;
				vao.Draw();
			});

			AttatchTextureAsColor(tex);
			Write(size, size, () {
				Copy(pressureTexture);
			});

			auto renderTex = pressureTexture;
			auto readivergenceTexture = tex;
			foreach (i; 0..11) { //諸事情により奇数回じゃないとダメ
				AttatchTextureAsColor(renderTex);
				Write(size, size, () {
					vao.shaderProgram = pCalc;
					pCalc.SetTexture(readivergenceTexture.texID, "mPressureTexture", 1);
					vao.Draw();
				});
				auto tmp = renderTex;
				renderTex = readivergenceTexture;
				readivergenceTexture = tmp;
			}

			AttatchTextureAsColor(tex);
			Write(size, size, () {
				Copy(velocityTexture);
			});

			AttatchTextureAsColor(velocityTexture);
			Write(size, size, () {
				vao.shaderProgram = vUpd;
				vao.Draw();
			});

			AttatchTextureAsColor(tex);
			Write(size, size, () {
				Copy(colorTexture);
			});

			AttatchTextureAsColor(colorTexture);
			Write(size, size, () {
				vao.shaderProgram = cAdv;
				vao.Draw();
			});

			AttatchTextureAsColor(tex);
			Write(size, size, () {
				Copy(velocityTexture);
			});

			AttatchTextureAsColor(velocityTexture);
			Write(size, size, () {
				vao.shaderProgram = vAdv;
				vao.Draw();
			});
			textureRenderFrameBuffer.UnBind();
		}
	}

	void Copy(TextureObject t) {
		copy.SetTexture(t.texID);
		vao.shaderProgram = copy;
		vao.Draw();
	}
}