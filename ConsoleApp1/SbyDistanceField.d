import derelict.glfw3.glfw3;
import derelict.opengl3.gl3;
import std.string;
import std.array;
import std.conv;
import std.typecons;
import std.algorithm;
import std.stdio;
import std.range;
import sbylib.imports;

class DistanceFieldMaterial {

	ShaderProgram depthWriter;
	private immutable string colorField;
	private immutable string distanceField;
	private string[] otherDeclaration;
	private immutable string materialName;
	private immutable int id;
	private static int id_seed = 2;
	mat4 transformMatrix = mat4.Identity();

	this(string materialName, string distanceField, string colorField, string[] otherDeclaration...) {
		this.colorField = colorField;
		this.distanceField = distanceField;
		this.materialName = materialName;
		this.id = id_seed++;
		this.otherDeclaration = otherDeclaration;
		distanceField = distanceField.replace("\t", "");
		distanceField = distanceField.replace("\n", "");
		auto vsSource = "
			attribute vec4 mVertex;
			attribute vec2 mTexcoord;
			uniform mat4 mWorld;
			uniform mat4 mViewProj;
			varying vec3 fragmentPosition; //ワールド座標でのあるピクセルの位置
			varying vec2 tc;
			void main() {
			fragmentPosition = (mWorld * mVertex).xyz;
			gl_Position = mViewProj * mWorld * mVertex;
			tc = mTexcoord;
			}
			";
		auto fsSource = "
			varying vec2 tc;
			varying vec3 fragmentPosition;
			uniform vec3 eye;
			uniform sampler2D mTexture; //The texture that is now being rendered.
			uniform float mFar;
			uniform mat4 mWorldInv;
			uniform vec3 vec;
			const float epsilon = 0.001;";

		foreach (dec; otherDeclaration)
			fsSource ~= dec;
		fsSource ~=
			"
			float GetDistance(vec3 pos) {
			"~ distanceField ~"
			}

			void main() {
			vec3 c = (mWorldInv * vec4(eye,1)).xyz;
			vec3 cameraVec = normalize((mWorldInv * vec4(fragmentPosition,1)).xyz - c);
			float depth = texture2D(mTexture, tc).r;
			float dist = 0;
			bool reached = false;
			float allDist = 0;
			for (int i = 0; i < 100; i++) {
			dist = GetDistance(c);
			allDist += dist;
			c += cameraVec * dist;
			//if (allDist > depth) break;
			if (dist < epsilon) {
			reached = true;
			break;
			}
			}
			if (reached) {
			gl_FragColor = vec4(allDist," ~ id.to!string ~ ", tc);
			}
			else
			gl_FragColor = vec4(0,0,0,0);//discard;
			}
			";
		depthWriter = new ShaderProgram(vsSource, fsSource, ShaderProgram.InputType.SourceCode);
	}

	alias depthWriter this;
}

class ScreenRenderer {

	public VertexArrayObject!float vao; //スクリーンに描画するためのVAO
	private DistanceFieldMaterial[string] materials; //統括するマテリアル情報
	private SbyRenderObject[] objects;
	private FrameBufferObject fbo; //オフスクリーンレンダリング用のVBO
	private TextureObject txo;
	private TextureObject debugTexture;
	private GLFWwindow *window;

	this(GLFWwindow *window) {
		fbo = new FrameBufferObject();
		int w, h;
		window.glfwGetWindowSize(&w, &h);
		txo = new TextureObject(w, h, GL_RGB32F);
		this.window = window;
		vao = new VertexArrayObject!float(4);
		debugTexture = new TextureObject("Resource/test.png");
	}

	//DistanceField式のシェーダを登録する
	void RegisterMaterial(DistanceFieldMaterial mat)
	in {
		//マテリアル名の重複は認めない。
		assert ((mat.materialName in materials) == null);
	}
	body {
		materials[mat.materialName] = mat;
	}

	void RegisterObject(SbyRenderObject object) {
		objects ~= object;
	}

	//最終レンダリング用のシェーダを生成する。乱用はよろしくない。
	void Update() {
		//頂点シェーダの宣言。こっちは別に大したことはない。
		string vsSource = "
			attribute vec2 mVertex;
			uniform mat4 mViewProjInv;
			varying vec2 tc;
			varying vec3 fragmentPosition; //あるピクセルのワールド空間での位置。スクリーンは視錐台の上面に一致する。
			void main() {
			gl_Position = vec4(mVertex, 0, 1);
			fragmentPosition = (mViewProjInv * vec4(mVertex, 0, 1)).xyz;
			tc = (mVertex + 1) * 0.5;
			}";
		//フラグメントシェーダの宣言。
		string fsSource;
		//変数、関数の宣言
		foreach (DistanceFieldMaterial mat; materials) {
			string source; //各マテリアルごとの宣言文
			Tuple!(string, string)[] replaceTable; //識別子の置換表
			foreach (d; mat.otherDeclaration) {
				foreach (lineNum,string line; d.split("\n")) {
					if (line.chomp.startsWith("//") || lineNum > 0) {
						source ~= line ~ "\n";
						continue;
					}
					auto strs = line.split(" ");
					if (strs.length == 0) {
						source ~= line ~ "\n";
						continue;
					}
					assert(strs[0] != "varying"); //varyingやuniform変数の宣言は認めない
					assert(strs[0] != "uniform");
					int i;
					//constがめんどいので避けとく。
					if (strs[0] == "const") {
						source ~= "const ";
						i = 1;
					} else {
						i = 0;
					}
					source ~= strs[i]; //返り値の型
					source ~= " ";
					//関数名の重複を考えて、関数名を変える。その際再帰している可能性を考慮し、replaceする。
					strs = strs[i+1..$];
					string funcName = strs[0].split("(")[0];
					string newFuncName = mat.materialName ~ "_" ~ funcName;
					source ~= reduce!((a, b) => a ~ " " ~ b)("", strs) ~ "\n";
					replaceTable ~= tuple(funcName, newFuncName);
					//ここまで関数ってことにしていたが、変数だとしてもそれはそれで問題なく動く。
				}
			}

			//距離関数を定義
			string newFuncName = "getDistance_" ~ mat.materialName;
			replaceTable ~= tuple("getDistance", newFuncName);
			source ~= "\nfloat getDistance(vec3 pos) {\n";
			foreach (s; mat.distanceField.split("\n")) {
				source ~= "\t" ~ s ~ "\n";
			}
			source ~= "}\n";

			//法線関数を定義
			newFuncName = "getNormal_" ~ mat.materialName;
			replaceTable ~= tuple("getNormal", newFuncName);
			source ~= "\nvec3 getNormal(vec3 pos) {
				const float epsilon = 0.000114514;
				return normalize(vec3(
				+ getDistance(vec3(pos.x + epsilon, pos.y, pos.z))
				- getDistance(vec3(pos.x - epsilon, pos.y, pos.z)),
				+ getDistance(vec3(pos.x, pos.y + epsilon, pos.z))
				- getDistance(vec3(pos.x, pos.y - epsilon, pos.z)),
				+ getDistance(vec3(pos.x, pos.y, pos.z + epsilon))
				- getDistance(vec3(pos.x, pos.y, pos.z - epsilon))
				));
				}\n";

			//色関数を定義
			newFuncName = "getColor_" ~ mat.materialName;
			replaceTable ~= tuple("getColor", newFuncName);
			source ~= "\nvec4 getColor(vec3 pos) {\n";
			foreach (s; mat.colorField.split("\n")) {
				source ~= "\t" ~ s ~ "\n";
			}
			source ~= "}\n";

			//識別子の置換を実行
			foreach (t; replaceTable) {
				source = source.replace(t[0], t[1]);
			}
			fsSource ~= source;
		}

		//本体
		fsSource ~= "
			varying vec2 tc;
			varying vec3 fragmentPosition;
			uniform sampler2D mTexture;
			uniform vec3 eye; //ワールド座標

			void main() {
			vec4 pixelInfo = texture2D(mTexture, tc);
			float depth = pixelInfo.r; //r成分にはカメラから衝突点までの距離を
			float id = pixelInfo.g; //g成分にはシェーダIDを

			vec3 pos = eye + normalize(fragmentPosition - eye) * depth;
			//色を計算
			vec4 color;
			\t";
		foreach (mat; materials) {
			fsSource ~= "if (id == " ~ mat.id.to!string ~ ")
				color = getColor_" ~ mat.materialName ~ "(pos);
				else ";
		}
		fsSource ~= "color = vec4(0, 1, 1, 1);
			gl_FragColor = color;
			}";
		auto sp = new ShaderProgram(vsSource, fsSource, ShaderProgram.InputType.SourceCode);
		vao.shaderProgram = sp;

		vao.UpdateVertex([
			-1,-1,0, 1,
			-1, 1,0, 1,
			1,-1,0, 1,
			1, 1,0, 1
		]);
	}

	void Draw() {
		//オフスクリーンレンダリング
		fbo.Bind();
		fbo.AttatchTextureAsColor(txo);
		int w,h;
		window.glfwGetWindowSize(&w, &h);

		fbo.Write(w, h, () {
			glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
			foreach (o; objects) {
				o.vao.SetUniformMatrix!(4, "mViewProj")((CurrentCamera.GetViewProjectionMatrix()).array());
				o.vao.SetUniform!(3, "eye")(CurrentCamera.Eye.array());
				o.vao.SetTexture(txo);
				o.Draw();
			}
		});
		fbo.UnBind();
		//スクリーンレンダリング
		vao.SetUniform!(3, "eye")(CurrentCamera.Eye.array());
		vao.SetUniformMatrix!(4, "mViewProjInv")(mat4.Invert(CurrentCamera.GetViewProjectionMatrix()).array());
		//vao.SetTexture(txo);
		//		vao.SetTexture(debugTexture);
		vao.Draw();
	}
}

abstract class SbyRenderObject {
	VertexArrayObject!float vao;
	protected bool vertexUpdateFlag = true;
	protected bool tcUpdateFlag = false;
	mat4 mWorld = mat4.Identity();

	@property VertexArrayObject!float Vao() {
		return vao;
	}

	this(DistanceFieldMaterial dfm) {
		vao = new VertexArrayObject!float(4);
		vao.shaderProgram = dfm;
	}

	void Draw() {
		if (vertexUpdateFlag) {
			//			vertexUpdateFlag = false;
			vec3[4] vertex;
			SetVertex(vertex);
			float[16] points;
			foreach (int i, ref v; vertex) {
				foreach (j; 0..3) points[i*4+j] = v[j];
				points[i*4+3] = 1;
			}
			vao.UpdateVertex(points);

		} else {
			vao.UpdateVertex();
		}
		if (tcUpdateFlag) {
			//			tcUpdateFlag = false;
			//			vec2[4] tc;
			//			SetTexcoords(tc);
			//			float[8] points;
			//			foreach (int i, ref v; tc) {
			//				foreach (j; 0..2) points[i*2+j] = v[j];
			//			}
			//			vao.UpdateTexcoords(points);
		} else {
		}
		auto mw = CurrentCamera.GetBillboardMatrix() * mWorld;
		vao.SetUniformMatrix!(4, "mWorld")(mw.array);
		vao.SetUniformMatrix!(4, "mWorldInv")(mat4.Invert(mWorld).array);
		vao.Draw();
	}

protected:
	abstract void SetVertex(out vec3[4] vertex);
	abstract void SetTexcoords(out vec2[4] tc);
}

class SphereBillboard : SbyRenderObject {

	private float radius = 0;

	mixin CreateSetterGetter!(radius, "vertexUpdateFlag = true;", "");

	this(DistanceFieldMaterial dfm, bool useTexture = false) {
		super(dfm);
		if (useTexture) tcUpdateFlag = true;
	}

	override void SetVertex(out vec3[4] vertex) {
		vec3 center = vec3(0,0,0);
		vertex[0] = center + (-vec3(1,0,0) - vec3(0,1,0)) * radius;
		vertex[1] = center + (+vec3(1,0,0) - vec3(0,1,0)) * radius;
		vertex[2] = center + (-vec3(1,0,0) + vec3(0,1,0)) * radius;
		vertex[3] = center + (+vec3(1,0,0) + vec3(0,1,0)) * radius;
	}

	override void SetTexcoords(out vec2[4] tc) {
		tc[0] = vec2(0, 0);
		tc[1] = vec2(1, 0);
		tc[2] = vec2(0, 1);
		tc[3] = vec2(1, 1);
	}

	alias vao this;
}

class Plane : SbyRenderObject {

	vec3[4] vertex;
	vec2[4] tc;

	this(DistanceFieldMaterial dfm) {
		super(dfm);
	}

	void BuildBasicPlane() {
		vertex[0] = vec3(-1, 0, -1);
		vertex[1] = vec3( 1, 0, -1);
		vertex[2] = vec3(-1, 0,  1);
		vertex[3] = vec3( 1, 0,  1);
		tc[0] = vec2(0, 0);
		tc[1] = vec2(1, 0);
		tc[2] = vec2(0, 1);
		tc[3] = vec2(1, 1);
		vertexUpdateFlag = tcUpdateFlag = true;
	}

	override void SetVertex(out vec3[4] vertex) {
		vertex[] = this.vertex[];
	}

	override void SetTexcoords(out vec2[4] tc) {
		tc[] = this.tc[];
	}

	alias vao this;
}