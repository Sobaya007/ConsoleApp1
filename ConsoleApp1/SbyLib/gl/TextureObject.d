module sbylib.gl.TextureObject;

import sbylib;

class TextureObject {
	import derelict.devil.il;
	import derelict.devil.ilu;
	import derelict.devil.ilut;

	immutable uint texID;
	immutable int width, height;

	static this() {
		DerelictIL.load();
		DerelictILU.load();
		DerelictILUT.load();
		ilInit();
		iluInit();
	}

	/*
	Params:
	filename = 読み込む画像の名前
	*/
	// Function load a image, turn it into a texture, and return the texture ID as a GLuint for use
	this(string filename)
	{
		uint imageID;				// Create an image ID as a ULuint

		uint textureID;			// Create a texture ID as a GLuint

		uint success;			// Create a flag to keep track of success/failure

		ILenum error;				// Create a flag to keep track of the IL error state

		ilGenImages(1, &imageID); 		// Generate the image ID

		ilBindImage(imageID); 			// Bind the image

		// match image origin to OpenGL’s
		success = ilutGLLoadImage(cast(ILstring)filename.toStringz);	// Load the image file

		// If we managed to load the image, then we can start to do things with it...
		if (success)
		{
			// If the image is flipped (i.e. upside-down and mirrored, flip it the right way up!)
			ILinfo ImageInfo;
			iluGetImageInfo(&ImageInfo);
			if (ImageInfo.Origin == IL_ORIGIN_UPPER_LEFT)
			{
				iluFlipImage();
			}

			// Convert the image into a suitable format to work with
			// NOTE: If your image contains alpha channel you can replace IL_RGB with IL_RGBA
			success = ilConvertImage(IL_RGB, IL_UNSIGNED_BYTE);

			// Quit out if we failed the conversion
			if (!success)
			{
				error = ilGetError();
				("Image conversion failed - IL reports error: " ~ to!string(error) ~ " - " ~ to!string(iluErrorString(error))).writeln;
			}

			// Generate a new texture
			glGenTextures(1, &textureID);

			// Bind the texture to a name
			glBindTexture(GL_TEXTURE_2D, textureID);

			// Set texture clamping method
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);

			// Set texture interpolation method to use linear interpolation (no MIPMAPS)
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);

			// Specify the texture specification
			glTexImage2D(GL_TEXTURE_2D, 				// Type of texture
						 0,				// Pyramid level (for mip-mapping) - 0 is the top level
						 ilGetInteger(IL_IMAGE_FORMAT),	// Internal pixel format to use. Can be a generic type like GL_RGB or GL_RGBA, or a sized type
						 ilGetInteger(IL_IMAGE_WIDTH),	// Image width
						 ilGetInteger(IL_IMAGE_HEIGHT),	// Image height
						 0,				// Border width in pixels (can either be 1 or 0)
						 ilGetInteger(IL_IMAGE_FORMAT),	// Format of image pixel data
						 GL_UNSIGNED_BYTE,		// Image data type
						 ilGetData());			// The actual image data itself
		}
		else // If we failed to open the image file in the first place...
		{
			error = ilGetError();
			auto errorStr = iluErrorString(error);
			("Image load failed - IL reports error: " ~ to!string(error)).writeln;
		}

		ilDeleteImages(1, &imageID); // Because we have already copied image data into texture data we can release memory used by image.

		"Texture creation successful.".writeln;

		this.texID = textureID;
		this.width = ilGetInteger(IL_IMAGE_WIDTH);
		this.height = ilGetInteger(IL_IMAGE_HEIGHT);

	}


	/*
	Params:
	width = テクスチャの幅
	height = テクスチャの高さ
	texMode = テクスチャの種類(GL_RBGなど)
	depthUse = テクスチャに深度バッファを使うか否か
	*/
	this(int width, int height, GLenum texMode) {
		// レンダリングしようとしているテクスチャ
		uint id;
		glGenTextures(1, &id);
		this.texID = id;

		Bind();

		// OpnGLに空の画像を与える(最後が"0")
		glTexImage2D(GL_TEXTURE_2D, 0, texMode, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, null);

		// フィルタリング
		SetMagFilter(TexFilterType.Linear);
		SetMinFilter(TexFilterType.Linear);
		SetWrapS(TexWrapType.Repeat);
		SetWrapT(TexWrapType.Repeat);

		this.width = width;
		this.height = height;

		UnBind();
	}

	enum TexFilterType {Linear = GL_LINEAR, Nearest = GL_NEAREST}

	void SetMagFilter(TexFilterType type) {
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, type);
	}

	void SetMinFilter(TexFilterType type) {
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, type);
	}

	enum TexWrapType {
		Repeat = GL_REPEAT,
		Clamp = GL_CLAMP,
		ClampToEdge = GL_CLAMP_TO_EDGE,
		ClampToBorder = GL_CLAMP_TO_BORDER,
		MirroredRepeat = GL_MIRRORED_REPEAT
	}

	void SetWrapS(TexWrapType type) {
		Bind();
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, type);
		UnBind();
	}

	void SetWrapT(TexWrapType type) {
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, type);
	}

	void Bind() {
		glBindTexture(GL_TEXTURE_2D, texID);
	}

	void UnBind() {
		glBindTexture(GL_TEXTURE_2D, 0);
	}

	alias texID this;
}