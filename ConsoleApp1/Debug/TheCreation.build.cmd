set PATH=C:\D\dmd2\windows\bin;C:\Program Files (x86)\Microsoft Visual Studio 14.0\\Common7\IDE;C:\Program Files (x86)\Windows Kits\8.0\\bin;%PATH%
set DMD_LIB=;DerelictLib

echo sbylib\camera\camera.d >Debug\TheCreation.build.rsp
echo sbylib\camera\orthocamera.d >>Debug\TheCreation.build.rsp
echo sbylib\camera\package.d >>Debug\TheCreation.build.rsp
echo sbylib\camera\perspectivecamera.d >>Debug\TheCreation.build.rsp
echo SbyLib\core\entity\drawable.d >>Debug\TheCreation.build.rsp
echo SbyLib\core\entity\entity.d >>Debug\TheCreation.build.rsp
echo sbylib\core\entity\package.d >>Debug\TheCreation.build.rsp
echo SbyLib\core\manipulator\manipulator.d >>Debug\TheCreation.build.rsp
echo SbyLib\core\manipulator\manipulatormanager.d >>Debug\TheCreation.build.rsp
echo sbylib\core\manipulator\package.d >>Debug\TheCreation.build.rsp
echo sbylib\core\manipulator\simplemover.d >>Debug\TheCreation.build.rsp
echo SbyLib\core\manipulator\simplerotator.d >>Debug\TheCreation.build.rsp
echo sbylib\core\package.d >>Debug\TheCreation.build.rsp
echo sbylib\core\window.d >>Debug\TheCreation.build.rsp
echo world.d >>Debug\TheCreation.build.rsp
echo SbyLib\gl\FrameBufferObject.d >>Debug\TheCreation.build.rsp
echo SbyLib\gl\IndexBufferObject.d >>Debug\TheCreation.build.rsp
echo sbylib\gl\package.d >>Debug\TheCreation.build.rsp
echo SbyLib\gl\RenderBufferObject.d >>Debug\TheCreation.build.rsp
echo SbyLib\gl\ShaderProgram.d >>Debug\TheCreation.build.rsp
echo SbyLib\gl\TextureObject.d >>Debug\TheCreation.build.rsp
echo SbyLib\gl\VertexArrayObject.d >>Debug\TheCreation.build.rsp
echo SbyLib\gl\VertexBufferObject.d >>Debug\TheCreation.build.rsp
echo sbylib\math\matrix.d >>Debug\TheCreation.build.rsp
echo sbylib\math\package.d >>Debug\TheCreation.build.rsp
echo sbylib\math\utils.d >>Debug\TheCreation.build.rsp
echo sbylib\math\vector.d >>Debug\TheCreation.build.rsp
echo sbylib\physics\bound\bound.d >>Debug\TheCreation.build.rsp
echo sbylib\physics\bound\obb.d >>Debug\TheCreation.build.rsp
echo sbylib\physics\bound\package.d >>Debug\TheCreation.build.rsp
echo sbylib\physics\bound\plane.d >>Debug\TheCreation.build.rsp
echo sbylib\physics\elastic\package.d >>Debug\TheCreation.build.rsp
echo sbylib\physics\elastic\sphere.d >>Debug\TheCreation.build.rsp
echo sbylib\physics\collisioninfo.d >>Debug\TheCreation.build.rsp
echo sbylib\physics\package.d >>Debug\TheCreation.build.rsp
echo SbyLib\primitive\box.d >>Debug\TheCreation.build.rsp
echo sbylib\primitive\package.d >>Debug\TheCreation.build.rsp
echo SbyLib\primitive\plane.d >>Debug\TheCreation.build.rsp
echo sbylib\primitive\primitive.d >>Debug\TheCreation.build.rsp
echo sbylib\primitive\sphere.d >>Debug\TheCreation.build.rsp
echo sbylib\shadertemplates\package.d >>Debug\TheCreation.build.rsp
echo SbyLib\shadertemplates\shaderstore.d >>Debug\TheCreation.build.rsp
echo SbyLib\utils\fpscounter.d >>Debug\TheCreation.build.rsp
echo SbyLib\utils\functions.d >>Debug\TheCreation.build.rsp
echo SbyLib\utils\package.d >>Debug\TheCreation.build.rsp
echo sbylib\package.d >>Debug\TheCreation.build.rsp
echo Import.d >>Debug\TheCreation.build.rsp
echo main.d >>Debug\TheCreation.build.rsp
echo Player.d >>Debug\TheCreation.build.rsp

dmd -g -debug -X -Xf"Debug\TheCreation.json" -Iderelict -deps="Debug\TheCreation.dep" -c -of"Debug\TheCreation.obj" @Debug\TheCreation.build.rsp
if errorlevel 1 goto reportError

set LIB="C:\D\dmd2\windows\bin\..\lib"
echo. > C:\Users\Sobaya\DOCUME~1\VISUAL~2\Projects\CONSOL~1\CONSOL~1\Debug\THECRE~1.LNK
echo "Debug\TheCreation.obj","Debug\TheCreation.exe","Debug\TheCreation.map",DerelictUtil.lib+ >> C:\Users\Sobaya\DOCUME~1\VISUAL~2\Projects\CONSOL~1\CONSOL~1\Debug\THECRE~1.LNK
echo DerelictGL3.lib+ >> C:\Users\Sobaya\DOCUME~1\VISUAL~2\Projects\CONSOL~1\CONSOL~1\Debug\THECRE~1.LNK
echo DerelictGLFW3.lib+ >> C:\Users\Sobaya\DOCUME~1\VISUAL~2\Projects\CONSOL~1\CONSOL~1\Debug\THECRE~1.LNK
echo DerelictIL.lib+ >> C:\Users\Sobaya\DOCUME~1\VISUAL~2\Projects\CONSOL~1\CONSOL~1\Debug\THECRE~1.LNK
echo DerelictFT.lib+ >> C:\Users\Sobaya\DOCUME~1\VISUAL~2\Projects\CONSOL~1\CONSOL~1\Debug\THECRE~1.LNK
echo user32.lib+ >> C:\Users\Sobaya\DOCUME~1\VISUAL~2\Projects\CONSOL~1\CONSOL~1\Debug\THECRE~1.LNK
echo kernel32.lib+ >> C:\Users\Sobaya\DOCUME~1\VISUAL~2\Projects\CONSOL~1\CONSOL~1\Debug\THECRE~1.LNK
echo DerelictLib\/NOMAP/CO/NOI/DELEXE /SUBSYSTEM:CONSOLE >> C:\Users\Sobaya\DOCUME~1\VISUAL~2\Projects\CONSOL~1\CONSOL~1\Debug\THECRE~1.LNK

"C:\Program Files (x86)\VisualD\pipedmd.exe" -deps Debug\TheCreation.lnkdep C:\D\dmd2\windows\bin\link.exe @C:\Users\Sobaya\DOCUME~1\VISUAL~2\Projects\CONSOL~1\CONSOL~1\Debug\THECRE~1.LNK
if errorlevel 1 goto reportError
if not exist "Debug\TheCreation.exe" (echo "Debug\TheCreation.exe" not created! && goto reportError)

goto noError

:reportError
echo Building Debug\TheCreation.exe failed!

:noError
