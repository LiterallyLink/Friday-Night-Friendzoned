@echo off
color 0a
cd ..
echo BUILDING GAME
haxelib run lime build windows -release
echo.
echo done.
pause

cd export\release\windows\bin
echo Attempting to run PsychEngine.exe...
start "" "%CD%\PsychEngine.exe"
pause