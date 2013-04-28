@echo off

echo CLEANING SOLUTION

if not exist "..\source" goto :eof
cd ..\source

del /a:h *.suo >nul 2>nul

if exist "build" (
	cd build
	call :rmdirifexists lib
	call :rmdirifexists mod
	mkdir lib
	mkdir mod
	rem del *.exe >nul 2>nul
	del *.manifest >nul 2>nul
	cd ..
)

for /f %%f in ('dir /a:d /b') do (
    cd %%f
	call :rmdirifexists Debug
	call :rmdirifexists Release
	del /a:h *.u2d >nul 2>nul
	del *.pdb >nul 2>nul
	del *.user >nul 2>nul
	cd ..
)


rem ==========================================================================
:rmdirifexists
	if exist %1 rmdir /s /q %1
    exit /b 0
rem ==========================================================================
