setlocal
:: Runs all Matlab unit tests for the latest GIT revision and e-mails results
:: 1. archName - string: architecture name, can be either win32 or win64


if "%~1"=="" (
	set archName=win64
) else (
	set archName=%1
)	

if "%archName%"=="win64" (
	set matlabBin="C:\Program Files\MATLAB\R2013b\bin\win64\matlab"
) else if "%archName%"=="win32" (
	set matlabBin="C:\Program Files (x86)\MATLAB\R2013b\bin\win32\matlab"
) else if "%archName%"=="win64_2015a" (
	set matlabBin="C:\Program Files\MATLAB\MATLAB Production Server\R2015a\bin\win64\matlab"
) else if "%archName%"=="win64_2015b" (
	set matlabBin="C:\Program Files\MATLAB\R2015b\bin\win64\matlab"
) else if "%archName%"=="win32_2015b" (
	set matlabBin="C:\Program Files (x86)\MATLAB\R2015b\bin\win32\matlab"
) else (
	echo %0: architecture %archName% not supported
	exit /b 1
)	
SET automationDir=%~dp0
set runMarker=win_%JOB_NAME%_%GIT_BRANCH%
echo runMarker=%runMarker%
set confName="default"
set genericBatScript=%automationDir%..\lib\mlunitext\automation\run_matlab_tests.bat
echo genericBatScript=%genericBatScript%
set deploymentDir=%automationDir%..\install
call %genericBatScript% %deploymentDir% elltool.test.run_tests_remotely %matlabBin% %runMarker% %confName%