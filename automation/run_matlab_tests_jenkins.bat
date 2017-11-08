setlocal
:: Runs all Matlab unit tests for the latest GIT revision and e-mails results
:: 1. archName - string: architecture name, can be either win32 or win64


if "%~1"=="" (
	set matlabVer=2017b
) else (
	set matlabVer=%1
)	

set matlabBin="C:\Program Files\MATLAB\R%matlabVer%\bin\win64\matlab"

SET automationDir=%~dp0
set runMarker="win_%JOB_NAME%_%GIT_BRANCH%"
echo runMarker=%runMarker%
set confName="default"
set genericBatScript=%automationDir%..\lib\mlunitext\automation\run_matlab_tests.bat
echo genericBatScript=%genericBatScript%
set deploymentDir=%automationDir%..\install
call %genericBatScript% %deploymentDir% elltool.test.run_tests_remotely %matlabBin% %runMarker% %confName%
