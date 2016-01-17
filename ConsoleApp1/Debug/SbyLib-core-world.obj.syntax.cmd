set PATH=C:\D\dmd2\windows\bin;C:\Program Files (x86)\Microsoft Visual Studio 14.0\\Common7\IDE;C:\Program Files (x86)\Windows Kits\8.1\\bin;%PATH%
set DMD_LIB=;DerelictLib
echo Compiling SbyLib\core\world.d...
dmd -g -debug -Iderelict -c -o- SbyLib\core\world.d
:reportError
if errorlevel 1 echo Compiling SbyLib\core\world.d failed!
if not errorlevel 1 echo Compilation successful.
