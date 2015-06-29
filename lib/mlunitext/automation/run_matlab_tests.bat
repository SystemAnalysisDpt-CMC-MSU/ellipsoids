@echo off
setlocal
:: Runs all Matlab unit tests for the latest GIT revision and e-mails results
::
:: Parameters:
:: 1. deploymentDir - string: name of deployment directory from where s_install script is called
:: 2. matlabFunc - string: name of Matlab function to run
:: 3. matlabBin - string: Matlab program path
:: 4. runMarker - string: Identifying string for the test
:: 5. confName - string: Test configuration name (optional)

echo ==== %0: %date% %time% Started =====

if "%~4"=="" (
	set runMarker=test
	if "%~3"=="" (
		set matlabBin=matlab
		if "%~2"=="" (
			echo %0: matlabFunc is an obligatory parameter
			exit /b 1		
		)
	) else (
		set matlabBin=%3
	)
) else (
    set runMarker=%4
)
set matlabFunc=%2
set deploymentDir=%1

echo ===== run_tests_remotely started: %date% %time% =====
@echo off
setlocal

set confName=%4
if defined confName (
	set mFile=%matlabFunc%('%runMarker%','%confName%')
) else (
	set mFile=%matlabFunc%('%runMarker%')
)
echo mFile=%mFile%
echo %logDir%
echo deploymentDir=%deploymentDir%

if %ERRORLEVEL% NEQ 0 (
	echo %0: update failed 1>&2
	exit /b 1
)

echo %0: Launching Matlab from %matlabBin%
cd %deploymentDir%
%matlabBin% -nodesktop -nosplash -singleCompThread -r "try, s_install, cd .., resVec=%mFile%, exit(0), catch meObj, disp(meObj.getReport()), exit(1), end"
 echo ==== %0: %date% %time% Done! =====