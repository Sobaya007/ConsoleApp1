module sbylib.shadertemplates.shaderstore;

import sbylib;

class ShaderStore {
	private static ShaderProgram[string] shaderList;

	static void Init() {

		/*
		法線を色として表示。
		Built-in : gl_Vertex
		uniform:   mWorld
				   mViewProj
		*/
		shaderList["NormalShow"] = new ShaderProgram(
													 "
													 uniform mat4 mWorld;
													 uniform mat4 mViewProj;
													 varying vec3 n;

													 void main() {
													 gl_Position = mViewProj * mWorld * gl_Vertex;
													 mat3 m2 = mat3(mWorld[0].xyz,mWorld[1].xyz,mWorld[2].xyz);
													 n = m2 * gl_Normal;
													 }",
													 "
													 varying vec3 n;
													 void main() {
													 gl_FragColor = vec4(n * .5 + .5,1);
													 }",
													 ShaderProgram.InputType.SourceCode);
		/*
		テクスチャ座標から白黒のチェック模様を表示。
		Built-in: gl_Vertex
				  gl_MultiTexCoord0
		uniform:  mWorld
				  mViewProj
		*/
		shaderList["Check"] = new ShaderProgram(
												"
												uniform mat4 mWorld;
												uniform mat4 mViewProj;
												varying vec3 n;
												varying vec2 tc;

												void main() {
												gl_Position = mViewProj * mWorld * gl_Vertex;
												mat3 m2 = mat3(mWorld[0].xyz,mWorld[1].xyz,mWorld[2].xyz);
												n = m2 * gl_Normal;
												tc = gl_MultiTexCoord0.xy;
												}",
												"
												varying vec3 n;
												varying vec2 tc;
												void main() {
												if ( ( mod(tc.x,0.1) - 0.05) * ( mod(tc.y,0.1) - 0.05) < 0) 
												gl_FragColor = vec4(.5,.5,.5,1);
												else
												gl_FragColor = vec4(0,0,0,1);
												}
												",
												ShaderProgram.InputType.SourceCode);
		/*
		グローバル座標系のx,y,z軸を表示。２次元専用。
		Built-in: gl_Vertex
		Uniform:  mView
		*/
		shaderList["Compass"] = new ShaderProgram("
												  varying vec2 tc;

												  void main() {
												  gl_Position = gl_Vertex;
												  tc = gl_Vertex.xy * .5;
												  }
												  ",
												  "
												  uniform mat4 mView;
												  varying vec2 tc;

												  float dist(vec2 v, vec2 p) {
												  float len = length(p);
												  float dot = dot(v, p);
												  return sqrt(len*len - dot*dot);
												  }

												  void main() {
												  vec4 xvec = vec4(1,0,0,0);
												  vec4 yvec = vec4(0,1,0,0);
												  vec4 zvec = vec4(0,0,1,0);
												  xvec = mView * xvec;
												  yvec = mView * yvec;
												  zvec = mView * zvec;
												  const float border = 0.01;
												  gl_FragColor = vec4(0,0,0,0);
												  if (length(tc) > 0.4) return;
												  if (dist(normalize(xvec.xy), tc) < border) gl_FragColor += vec4(1, 0, 0, 1) * (dot(xvec.xy, tc) < 0 ? 0.5 : 1);
												  if (dist(normalize(yvec.xy), tc) < border) gl_FragColor += vec4(0, 1, 0, 1) * (dot(yvec.xy, tc) < 0 ? 0.5 : 1);
												  if (dist(normalize(zvec.xy), tc) < border) gl_FragColor += vec4(0, 0, 1, 1) * (dot(zvec.xy, tc) < 0 ? 0.5 : 1);
												  }
												  ",
												  ShaderProgram.InputType.SourceCode);
		shaderList["Phong"] = new ShaderProgram(
												"
												uniform mat4 mWorld;
												uniform mat4 mViewProj;
												varying vec4 p;
												varying vec3 n;

												void main() {
												gl_Position = mViewProj * mWorld * gl_Vertex;
												mat3 m2 = mat3(mWorld[0].xyz,mWorld[1].xyz,mWorld[2].xyz);
												n = m2 * gl_Normal;
												p = mWorld * gl_Vertex;
												}",
												"
												uniform vec4 lightPos;
												uniform vec3 cameraPos;

												varying vec4 p;
												varying vec3 n;

												void main() {

												vec3 ambient = (n * 0.5+ 0.5) * 0.5;
												vec3 diffuse = n * 0.5+ 0.5;
												vec3 specular = vec3(1,1,1);
												vec3 pos = p.xyz / p.w;
												gl_FragColor.xyz = 
												+ ambient
												+ diffuse * max(0, dot( normalize(lightPos.xyz - pos), n ))
												+ specular * pow(max(0, dot( normalize(cameraPos - pos), normalize(reflect(pos - lightPos.xyz, n)))), 20);
												gl_FragColor.w = 1;
												}",
												ShaderProgram.InputType.SourceCode);

		/*
		指定した色でポリゴンを塗りつぶし
		Built-in: gl_Vertex
		Uniform:  mWorld
				  mViewProj
				  color
		*/	
		shaderList["SimpleColor"] = new ShaderProgram(
												"
												uniform mat4 mWorld;
												uniform mat4 mViewProj;

												void main() {
												gl_Position = mViewProj * mWorld * gl_Vertex;
												}",
												"
												uniform vec4 color;
												void main() {
												gl_FragColor = color;
												}
												",
												ShaderProgram.InputType.SourceCode);

		/*
		DrawRect用。矩形を指定した色で塗りつぶす。
		Built-in: gl_Vertex
		Uniform:  cx       ピクセル単位での矩形の中心座標
				  cy
				  width    ピクセル単位での矩形の大きさ
				  height
				  ww       ピクセル単位でのウインドウの大きさ
				  wh
				  color
		*/
		shaderList["DrawRect"] = new ShaderProgram("
												   uniform float cx, cy, width, height, ww, wh;

												   void main() {
												   vec2 v = gl_Vertex.xy;
												   v.x *= width  / ww;
												   v.y *= height / wh;
												   v.x += cx / ww * 2 - 1;
												   v.y += cy / wh * 2 - 1;
												   gl_Position = vec4(v, 0, 1);
												   }
												   ",
												   "
												   uniform vec4 color;
												   void main() {
												   gl_FragColor = vec4(color);
												   }
												   ",
												   ShaderProgram.InputType.SourceCode);

		/*
		DrawImage用。矩形領域に指定した画像を貼る。	
		Built-in: gl_Vertex
		Uniform:  cx       ピクセル単位での矩形の中心座標
		cy
		width    ピクセル単位での矩形の大きさ
		height
		ww       ピクセル単位でのウインドウの大きさ
		wh
		mTexture
		*/
		shaderList["DrawImage"] = new ShaderProgram("uniform float cx, cy, width, height, ww, wh;
													varying vec2 tc;

													void main() {
													vec2 v = gl_Vertex.xy;
													v.x *= width  / ww;
													v.y *= height / wh;
													v.x += cx / ww * 2 - 1;
													v.y += cy / wh * 2 - 1;
													gl_Position = vec4(v, 0, 1);
													tc = gl_Vertex.xy * .5 + .5;
													}
													",
													"
													uniform sampler2D mTexture;
													varying vec2 tc;
													void main() {
													gl_FragColor = texture2D(mTexture, tc);
													}
													",
													ShaderProgram.InputType.SourceCode);
	}

	static ShaderProgram getShader(string key) {
		return shaderList[key];
	}
}