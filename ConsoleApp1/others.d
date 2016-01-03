module sbylib.others;

import sbylib.imports;
//
//VertexArrayObject!float Doushiyoumonai() {
//    VertexArrayObject!float result = new VertexArrayObject!float(4);
//    result.shaderProgram = new ShaderProgram("Shader/Fluid/TestShader.vert", "Shader/Simple.frag", ShaderProgram.InputType.FilePath);
//    result.shaderProgram.SetTexture(new TextureObject("Resource/test.png"));
//    result.UpdateVertex([
//        -1,-1,0, 1,
//        -1, 1,0, 1,
//         1,-1,0, 1,
//         1, 1,0, 1]
//    );
//
//    return result;
//}



//class TextTextureObject : TextureObject {
//
//	private:
//	uint charTexID;
//	VertexArrayObject vao;
//
//	public:
//	this(uint renderFrameBuffer, int width, int height, GLenum texMode, bool depthUse = false) {
//		super(renderFrameBuffer, width, height, texMode, depthUse);
//		vao = new VertexArrayObject("TextShader.vert", "TextShader.frag");
//	}
//
//	void RenderText(string text, float x, float y, float sx, float sy) {
//		char *p = cast(char*)text.toStringz;
//
//		for(; *p; p++) {
//			if(FT_Load_Char(face, *p, FT_LOAD_TARGET_MONO))
//				continue;
//			FT_Render_Glyph(face.glyph, FT_Render_Mode.FT_RENDER_MODE_NORMAL);
//
//			float x2 =  x + g.bitmap_left * sx;
//			float y2 = -y - g.bitmap_top * sy;
//			float w = g.bitmap.width * sx;
//			float h = g.bitmap.rows * sy;
//
//			float[16] box = [
//				x2,     -y2 - h, 0, 0,
//				x2 + w, -y2 - h, 1, 0,
//				x2,     -y2    , 0, 1,
//				x2 + w, -y2    , 1, 1,
//			];
//
//			RenderCharacter(box);
//
//			x += (g.advance.x >> 6) * sx/2;
//			y += (g.advance.y >> 6) * sy;
//		}
//	}
//
//	private void RenderCharacter(float[16] box) {
//		//charTexに一文字だけ書き込み
//		glGenTextures(1, &charTexID);
//
//		// 新たに作ったテクスチャをバインドする : この後のテクスチャに関する関数は、このテクスチャに対して行われる。
//		glBindTexture(GL_TEXTURE_2D, charTexID);
//		// フィルタリング
//		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
//		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
//		glTexImage2D(
//					 GL_TEXTURE_2D,
//					 0,
//					 GL_RED,
//					 g.bitmap.width*2,
//					 g.bitmap.rows/2,
//					 0,
//					 GL_RED,
//					 GL_UNSIGNED_BYTE,
//					 g.bitmap.buffer
//					 );
//		//charTexをthisに書き込み
//		vao.shaderProgram.SetTexture(charTexID);
//		vao.UpdateVertex(box);
//		Write(() {
//			vao.Draw();
//		});
//		glDeleteTextures(1, &charTexID);
//	}
//}


