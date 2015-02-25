@echo off
echo Detecting OS processor type

if "%PROCESSOR_ARCHITECTURE%"=="AMD64" goto 64BIT
echo 32-bit OS
cd software\windows\x86
goto END
:64BIT
echo 64-bit OS
cd software\windows\x64
:END
setup.exe
echo coming out of batch script
