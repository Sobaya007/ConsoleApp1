set PATH=C:\D\dmd2\windows\bin;C:\Program Files (x86)\Microsoft Visual Studio 14.0\\Common7\IDE;C:\Program Files (x86)\Windows Kits\8.0\\bin;%PATH%
set DMD_LIB=;DerelictLib

echo Camera.d >Debug\TheCreation.build.rsp
echo SbyLib\Manipulator.d >>Debug\TheCreation.build.rsp
echo sbylib\gl\FrameBufferObject.d >>Debug\TheCreation.build.rsp
echo sbylib\gl\imports.d >>Debug\TheCreation.build.rsp
echo sbylib\gl\IndexBufferObject.d >>Debug\TheCreation.build.rsp
echo sbylib\gl\RenderBufferObject.d >>Debug\TheCreation.build.rsp
echo sbylib\gl\ShaderProgram.d >>Debug\TheCreation.build.rsp
echo sbylib\gl\TextureObject.d >>Debug\TheCreation.build.rsp
echo sbylib\gl\VertexArrayObject.d >>Debug\TheCreation.build.rsp
echo sbylib\gl\VertexBufferObject.d >>Debug\TheCreation.build.rsp
echo sbylib\fpscounter.d >>Debug\TheCreation.build.rsp
echo functions.d >>Debug\TheCreation.build.rsp
echo sbylib\imports.d >>Debug\TheCreation.build.rsp
echo math.d >>Debug\TheCreation.build.rsp
echo others.d >>Debug\TheCreation.build.rsp
echo package.d >>Debug\TheCreation.build.rsp
echo primitive.d >>Debug\TheCreation.build.rsp
echo world.d >>Debug\TheCreation.build.rsp
echo Import.d >>Debug\TheCreation.build.rsp
echo main.d >>Debug\TheCreation.build.rsp
echo Player.d >>Debug\TheCreation.build.rsp

dmd -g -debug -X -Xf"Debug\TheCreation.json" -Iderelict -deps="Debug\TheCreation.dep" -c -of"Debug\TheCreation.obj" @Debug\TheCreation.build.rsp
if errorlevel 1 goto reportError

set LIB="C:\D\dmd2\windows\bin\..\lib";\dm\lib
echo. > C:\Users\Sobaya\DOCUME~1\VISUAL~2\Projects\CONSOL~1\CONSOL~1\Debug\THECRE~1.LNK
echo "Debug\TheCreation.obj","Debug\TheCreation.exe","Debug\TheCreation.map",DerelictUtil.lib+ >> C:\Users\Sobaya\DOCUME~1\VISUAL~2\Projects\CONSOL~1\CONSOL~1\Debug\THECRE~1.LNK
echo DerelictGL3.lib+ >> C:\Users\Sobaya\DOCUME~1\VISUAL~2\Projects\CONSOL~1\CONSOL~1\Debug\THECRE~1.LNK
echo DerelictGLFW3.lib+ >> C:\Users\Sobaya\DOCUME~1\VISUAL~2\Projects\CONSOL~1\CONSOL~1\Debug\THECRE~1.LNK
echo DerelictIL.lib+ >> C:\Users\Sobaya\DOCUME~1\VISUAL~2\Projects\CONSOL~1\CONSOL~1\Debug\THECRE~1.LNK
echo DerelictFT.lib+ >> C:\Users\Sobaya\DOCUME~1\VISUAL~2\Projects\CONSOL~1\CONSOL~1\Debug\THECRE~1.LNK
echo user32.lib+ >> C:\Users\Sobaya\DOCUME~1\VISUAL~2\Projects\CONSOL~1\CONSOL~1\Debug\THECRE~1.LNK
echo kernel32.lib+ >> C:\Users\Sobaya\DOCUME~1\VISUAL~2\Projects\CONSOL~1\CONSOL~1\Debug\THECRE~1.LNK
echo DerelictLib\/NOMAP/CO/NOI/DELEXE >> C:\Users\Sobaya\DOCUME~1\VISUAL~2\Projects\CONSOL~1\CONSOL~1\Debug\THECRE~1.LNK

"C:\Program Files (x86)\VisualD\pipedmd.exe" -deps Debug\TheCreation.lnkdep C:\D\dmd2\windows\bin\link.exe @C:\Users\Sobaya\DOCUME~1\VISUAL~2\Projects\CONSOL~1\CONSOL~1\Debug\THECRE~1.LNK
if errorlevel 1 goto reportError
if not exist "Debug\TheCreation.exe" (echo "Debug\TheCreation.exe" not created! && goto reportError)

goto noError

:reportError
echo Building Debug\TheCreation.exe failed!

:noError
