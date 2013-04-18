@echo off

cd ..

echo CLEANING SOLUTION

del /a:h *.suo >nul 2>nul

cd run
for /f %%f in ('dir /a:d /b') do (
	call :rmdirifexists %%f
)
cd ..

cd build
call :rmdirifexists lib
call :rmdirifexists mod
mkdir lib
mkdir mod
del *.exe >nul 2>nul
del *.manifest >nul 2>nul
cd ..

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
