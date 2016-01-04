module sbylib.primitive;

import sbylib.imports;

abstract class Primitive {
	public abstract void Draw();

	protected mat4 mat = mat4.Identity;

	void opOpAssign(string op)(vec3 v) {
		static if (op == "*") {
			mat = mat * mat4.Scale(v);
		}
	}
}

class Box : Primitive {

	private VAO vao;
	private ShaderProgram sp;
	private VBO vbo;
	private IBO index;

	this() {
		vao = new VAO;
		sp = new ShaderProgram(
			"uniform mat4 mWorld;
			uniform mat4 mViewProj;
			void main() {
				gl_Position = mViewProj * mWorld * gl_Vertex;
			}",
			"void main() {
				gl_FragColor = vec4(1,1,0,1);
			}",
			ShaderProgram.InputType.SourceCode);
		vao.shaderProgram = sp;
		vbo = new VBO( [
			-1,-1,0,1f,
			+1,-1,0,1,
			-1,+1,0,1,
			+1,+1,0,1,
			-1,-1,1,1,
			+1,-1,1,1,
			-1,+1,1,1,
			+1,+1,1,1
		], VBO.Frequency.DYNAMIC);
		vao.Bind();
		vbo.Bind();
		glEnableClientState(GL_VERTEX_ARRAY);
		glVertexPointer(4, GL_FLOAT, 0, null);
		vbo.UnBind();
		vao.UnBind();
		index = new IBO([0,1,2,3], IBO.Frequency.DYNAMIC);
	}

	override void Draw() {
		sp.SetUniformMatrix!(4,"mWorld")(mat.array);
		sp.SetUniformMatrix!(4,"mViewProj")(CurrentCamera.GetViewProjectionMatrix.array);
		vao.Draw();
	}
}