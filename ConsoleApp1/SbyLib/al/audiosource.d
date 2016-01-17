module sbylib.al.audiosource;

import sbylib;

class AudioSource {
public:
	uint src;
	uint buf;
public:

	this(string filePath) {
		// 音源を作成
		alGenSources(1, &src);

		// ファイルから読み込み
		buf = alureCreateBufferFromFile(cast(char*)filePath.toStringz);
		if (buf == AL_NONE) {
			assert(false, "Failed to load from file!");
		}

		// バッファを音源に設定して
		alSourcei(src, AL_BUFFER, buf);
	}

	~this() {
		//alDeleteSources(1, &src);
		//alDeleteBuffers(1, &buf);
	}

	void Play() {
		alSourcePlay(src);
	}

	void SetIsRelative(bool relative) {
		alSourcei(src, AL_SOURCE_RELATIVE, relative ? AL_TRUE : AL_FALSE);
	}

	void SetLoop(bool loop) {
		alSourcei(src, AL_LOOPING, loop ? AL_TRUE : AL_FALSE);
	}
}