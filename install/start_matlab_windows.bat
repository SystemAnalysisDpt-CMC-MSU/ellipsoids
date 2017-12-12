:: Start matlab
::
:: Parameters:
:: 1. matlabExe: Path to the Matlab executable (not launcher!) on the local machine
::		if not specified Matlab is called just via "matlab" command thus exact Matlab
::		version is determined by "PATH" environment variable
:: 2. isDesktopUsed: boolean, if false - run with "-nodesktop" option
::
:: Example:
::
:: start_matlab_tests "C:\Program Files\MATLAB\R2013b\bin\win64\matlab.exe"
setlocal ENABLEEXTENSIONS

set matlabExe=%~1

if "%~1"=="" (
	set matlabExe=matlab
)

if "%~2"=="" (
	set isDesktopUsed=true
) else (
	set isDesktopUsed=%2
)
if "%isDesktopUsed%"=="true" (
	set matlabArg=-desktop
) else if "%isDesktopUsed%"=="false" (
	set matlabArg=-nodesktop -nosplash
) else (
	echo %0: isDesktopUsed can only be "true" or "false"
	exit /b 1
)

echo isDesktopUsed matlabArg
echo %isDesktopUsed% %matlabArg%

set script=%~n0
set scriptDir=%~dp0
set curDir=%cd%
echo ==== %script%: %date% %time% Started =====

set matlabCommand=s_install, cd ..

cd %scriptDir%
"%matlabExe%" %matlabArg% -singleCompThread -r "%matlabCommand%" -logfile startlog.log


set isFailed=%ERRORLEVEL%
cd %curDir%
echo ==== %script%: %date% %time% Finished =====

exit /B %isFailed%