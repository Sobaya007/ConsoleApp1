module sbylib.physics.elastic.sphere;

import sbylib;

class ElasticSphere : Primitive {

	static{
		private {
			ShaderProgram sp;
			IBO index;
			vec3[] vertex;
			uint[] indices;
			uint[][] pairIndex;
			vec3[] dList;

			immutable {
				int recursionLevel = 2;
				float R = 0.5;
				float h = 0.02;
				float zeta = 0.5;
				float omega = 1000;
				float m = 0.1;
				float c = 2 * zeta * omega * m;
				float k = m * omega * omega;
				float deflen = R * 2 * (1 - 1 / sqrt(5.0f)) / (recursionLevel + 1);
				float friction = 0.3;
				float gravity = 10;

				float velocity_coefficient = 1 / (1+h*c/m+h*h*k/m);
				float position_coefficient = - (h*k/m) / (1+h*c/m+h*h*k/m);
			}
		}

	}

	static this() {
		enum goldenRatio = (1 + sqrt(5.0f)) / 2;

		vertex ~= vec3(-1, +goldenRatio, 0);
		vertex ~= vec3(+1, +goldenRatio, 0);
		vertex ~= vec3(-1, -goldenRatio, 0);
		vertex ~= vec3(+1, -goldenRatio, 0);

		vertex ~= vec3(0, -1, +goldenRatio);
		vertex ~= vec3(0, +1, +goldenRatio);
		vertex ~= vec3(0, -1, -goldenRatio);
		vertex ~= vec3(0, +1, -goldenRatio);

		vertex ~= vec3(+goldenRatio, 0, -1);
		vertex ~= vec3(+goldenRatio, 0, +1);
		vertex ~= vec3(-goldenRatio, 0, -1);
		vertex ~= vec3(-goldenRatio, 0, +1);

		foreach (i; 0..vertex.length) vertex[i] = normalize(vertex[i]);

		indices ~= [ 5, 11,  0];
		indices ~= [ 1,  5,  0];
		indices ~= [ 7,  1,  0];
		indices ~= [10,  7,  0];
		indices ~= [11, 10,  0];

		indices ~= [ 9,  5,  1];
		indices ~= [ 4, 11,  5];
		indices ~= [ 2, 10, 11];
		indices ~= [ 6,  7, 10];
		indices ~= [ 8,  1,  7];

		indices ~= [ 4,  9,  3];
		indices ~= [ 2,  4,  3];
		indices ~= [ 6,  2,  3];
		indices ~= [ 8,  6,  3];
		indices ~= [ 9,  8,  3];

		indices ~= [ 5,  9,  4];
		indices ~= [11,  4,  2];
		indices ~= [10,  2,  6];
		indices ~= [ 7,  6,  8];
		indices ~= [ 1,  8,  9];

		int idx = 12;
		//解像度細かく
		foreach (k; 0..recursionLevel) {

			uint[uint] cache;
			uint getMiddle(uint a, uint b) {
				uint pair = a < b ? (a * 114514 + b) : (b *	114514 + a);
				uint* r = pair in cache;
				if (r != null) {
					return *r;
				}
				auto newVertex = normalize(vertex[a] + vertex[b]);
				vertex ~= newVertex;
				cache[pair] = idx;
				return idx++;
			}
			uint[] indices2;
			foreach (i; 0..indices.length/3) { //各面について

				uint v0 = getMiddle(indices[i*3+0],indices[i*3+1]);
				uint v1 = getMiddle(indices[i*3+1],indices[i*3+2]);
				uint v2 = getMiddle(indices[i*3+2],indices[i*3+0]);

				indices2 ~= [indices[i*3+0], v0, v2];
				indices2 ~= [v0, indices[i*3+1], v1];
				indices2 ~= [v2,v1,indices[i*3+2]];
				indices2 ~= [v0, v1, v2];
			}
			indices = indices2.dup;
		}

		uint[] makePair(uint a, uint b) {
			return a < b ? [a,b] : [b,a];
		}
		//隣を発見
		foreach (i; 0..indices.length/3) {
			auto idx0 = indices[i*3];
			auto idx1 = indices[i*3+1];
			auto idx2 = indices[i*3+2];

			if (pairIndex.canFind(makePair(idx0,idx1)) == false) pairIndex ~= makePair(idx0,idx1);
			if (pairIndex.canFind(makePair(idx1,idx2)) == false) pairIndex ~= makePair(idx1,idx2);
			if (pairIndex.canFind(makePair(idx2,idx0)) == false) pairIndex ~= makePair(idx2,idx0);
		}
		dList = new vec3[pairIndex.length];
	}

	private {
		Particle[] particleList;
		VAO vao;
		VBO vertexVBO;
		VBO normalVBO;

		TextureObject particleInfoTexture;
	}

	this()  {
		sp = ShaderStore.getShader("NormalShow");


		float[] vertexArray;
		foreach (v; vertex) vertexArray ~= v.array;

		vertexVBO = new VBO( vertexArray, VBO.Frequency.STREAM);

		//法線
		float[] normal;

		foreach (v; vertex) {
			auto n = normalize(v);
			normal ~= n.array;
		}
		normalVBO = new VBO(normal, VBO.Frequency.STATIC);

		//インデックス
		index = new IBO(indices, IBO.Frequency.STATIC);

		//VAO設置
		vao = new VAO;
		vao.shaderProgram = sp;
		vao.mode = GL_TRIANGLES;

		vao.Bind();
		{	

			normalVBO.Bind();
			{
				glEnableClientState(GL_NORMAL_ARRAY);
				glNormalPointer(GL_FLOAT, 0, null);
			}
			normalVBO.UnBind();

			vertexVBO.Bind();
			{
				glEnableClientState(GL_VERTEX_ARRAY);
				glVertexPointer(3, GL_FLOAT, 0, null);
			}
			vertexVBO.UnBind();
		}
		vao.UnBind();

		//パーティクル初期化
		foreach (v; vertex) {
			particleList ~= new Particle(v);
		}

		int n = cast(int)ceil(log2(vertex.length));

		//GPGPUの準備
		particleInfoTexture = new TextureObject(2^^n, 1, GL_RGBA);
	}

	override void Draw() {
		sp.SetUniformMatrix!(4,"mWorld")(mat4.Identity.array);
		sp.SetUniformMatrix!(4,"mViewProj")(CurrentCamera.GetViewProjectionMatrix.array);
		vao.Draw(index);

		Move();

		float[] vertexArray;
		foreach (ref p;particleList) {
			vertexArray ~= p.p.array;
		}
		vertexVBO.Update(vertexArray);

	}

	void Move() {
		immutable N = particleList.length;
		//隣との拘束
		{
			foreach (i; 0..pairIndex.length) {
				vec3 d = particleList[pairIndex[i][1]].p - particleList[pairIndex[i][0]].p;	
				auto len = d.length;
				if (len > 0) d /= len;
				len -= deflen;
				d *= len;
				dList[i] = d;
			}
			foreach (k; 0..100){
				foreach (i; 0..pairIndex.length) {
					auto id0 = pairIndex[i][0], id1 = pairIndex[i][1];
					vec3 v1 = particleList[id1].v - particleList[id0].v;
					vec3 v2 = v1 * velocity_coefficient + dList[i] * position_coefficient;
					vec3 dv = (v2 - v1) * 0.5f;
					particleList[id0].v -= dv;
					particleList[id1].v += dv;
				}
			}
		}
		//体積の測定
		float volume = 0;
		{
			int base = indices[0];
			foreach (i; 0..indices.length/3) {
				int idx0 = indices[i*3+0]; 
				int idx1 = indices[i*3+1];
				int idx2 = indices[i*3+2];
				volume += -computeSignedVolume!float([particleList[base].p, particleList[idx0].p, particleList[idx1].p, particleList[idx2].p]) / 6;
			}
		}
		//表面積の測定
		float area = 0;
		{
			foreach (i; 0..indices.length/3) {
				int idx0 = indices[i*3+0]; 
				int idx1 = indices[i*3+1];
				int idx2 = indices[i*3+2];
				area += computeUnSignedArea!float([particleList[idx0].p, particleList[idx1].p, particleList[idx2].p]) / 2;
			}
		}
		//ちょっとふくらませる
		{
			float force = 20;
			foreach (i; 0..N) {
					Particle p = particleList[i];
				p.v += p.n * force;
			}
		}

		vec3 g = vec3(0,0,0);
		foreach (p; particleList) g += p.p;
		g /= particleList.length;
		Pos = g;
		if (Or(&CurrentWindow.isKeyPressed, KeyButton.Space, KeyButton.Enter)) {
			foreach (p; particleList) {
				if (p.p.y > g.y) {
					float len = length(p.p.xz - g.xz);
					p.v.y -= 5 / len;
				}
			}
		}
		{
			enum force = 3;
			vec3 f = vec3(0,0,0);
			with (CurrentWindow) {

				if (isKeyPressed(KeyButton.A)) {
					f -= CurrentCamera.GetVecX * force;
				}
				if (isKeyPressed(KeyButton.D)) {
					f += CurrentCamera.GetVecX * force;
				}
				if (isKeyPressed(KeyButton.W)) {
					f += CurrentCamera.GetVecZ * force;
				}
				if (isKeyPressed(KeyButton.S)) {
					f -= CurrentCamera.GetVecZ * force;
				}
			}
			foreach (p; particleList) {
				if (p.isGround)
				p.v += f;
			}

		}


		//マウス座標で動かす

		vec4 color = vec4(1,1,1,1);

		Ray ray = CurrentCamera.GetCameraRay(CurrentWindow.getMousePos);
		auto mp = ray.GetPos - ray.GetPos.y / ray.vector.y * ray.vector;

		foreach (p; particleList) {
			vec3 d = p.p - mp;
			float len;
			if ((len = d.length) < 1) {
				enum force = 0.2;
				p.v += d / len * force;
				color = vec4(1,1,0,1);
			}
		}

		DrawRect(0,0,300,300, color);

		foreach (i; 0..N) {
			particleList[i].move();
		}

	}

	class Particle {
		vec3 p;
		vec3 v;
		vec3 n;
		bool isGround;

		this(vec3 p) {
			this.p = p;
			this.n = normalize(p);
			this.v = vec3(0,10,0);
		}

		void move() {
			p += v * h;
 
			v.y -= gravity * h;

			isGround = false;

			if (p.y < 0) {
				p.y = 0;
				v.y = 0;
				v.xz = v.xz * (1 - friction);
				isGround = true;
			}
		}
	}	
}
