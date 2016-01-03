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
	private IBO index;

	this() {
		vao = new VertexArrayObject!float(4);
		vao.shaderProgram = new ShaderProgram(
			"attribute vec4 mVertex;
			uniform mat4 mWorld;
			uniform mat4 mViewProj;
			void main() {
				gl_Position = mViewProj * mWorld * mVertex;
			}",
			"void main() {
				gl_FragColor = vec4(1,1,0,1);
			}",
			ShaderProgram.InputType.SourceCode);
		vao.UpdateVertex([
			-1,-1,0,1,
			+1,-1,0,1,
			-1,+1,0,1,
			+1,+1,0,1,
			-1,-1,1,1,
			+1,-1,1,1,
			-1,+1,1,1,
			+1,+1,1,1
		]);
		index = new IBO([0,1,2,3], IBO.Frequency.DYNAMIC);
	}

	override void Draw() {
		vao.SetUniformMatrix!(4,"mWorld")(mat.array);
		vao.SetUniformMatrix!(4,"mViewProj")(CurrentCamera.GetViewProjectionMatrix.array);
		vao.Draw(index);
	}
}