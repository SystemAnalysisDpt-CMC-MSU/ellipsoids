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
::remove double quotes if any
set runMarker=%runMarker:"=%

set matlabFunc=%2
set deploymentDir=%1

echo ===== run_tests_remotely started: %date% %time% =====

setlocal

set confName=%4
if defined confName (
	set matlabCmd=%matlabFunc%('%runMarker%','%confName%')
) else (
	set matlabCmd=%matlabFunc%('%runMarker%')
)

SET curDir=%~dp0

echo just start and close matlab
call %curDir%run_matlab_cmd.bat %deploymentDir% %matlabBin%
echo just start matlab and run tests
call %curDir%run_matlab_cmd.bat %deploymentDir% %matlabBin% "%matlabCmd%"