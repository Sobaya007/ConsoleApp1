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

	//private VAO vao;
	private ShaderProgram sp;
	private VBO vbo;
	private IBO index;

	this() {
		//vao = new VertexArrayObject!float(4);
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
		vbo.Bind();
		glEnableClientState(GL_VERTEX_ARRAY);
		glVertexPointer(4, GL_FLOAT, 0, null);
		vbo.UnBind();
		//vao.Se4tVertex(vbo);
		index = new IBO([0,1,2,3], IBO.Frequency.DYNAMIC);
	}

	override void Draw() {
		auto f = {writeln("Hello");};
		f();
		sp.SetUniformMatrix!(4,"mWorld")(mat.array);
		sp.SetUniformMatrix!(4,"mViewProj")(CurrentCamera.GetViewProjectionMatrix.array);
		sp.Use();
		sp.Uniform();
		vbo.Bind();
		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	}
}