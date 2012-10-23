@echo off
setlocal
:: Runs all Matlab unit tests for the latest SVN revision and e-mails results
::
:: Parameters:
:: 1. svnRoot - string: SVN root directory for the project
:: 2. matlabDir - string: Relative path to Matlab source dir within the SVN dir
:: 3. logDir - string: Relative path to the log dir within the SVN dir
:: 4. matlabBin - string: Matlab program path
:: 5. runMarker - string: Identifying string for the test
:: 6. confName - string: Test configuration name (optional)
::
:: Example:
:: run_matlab_tests.bat C:\SVN_Local\TrunkLatest Sources\Matlab ^
::   Sources\scheduling\log "C:\Matlab2012a" ^
::   devel_iv_sd_test_trunk forecaster trunk

echo ==== %0: %date% %time% Started =====

if "%~5"=="" (
	echo %0: Too few parameters 1>&2
	exit /b 1
)

set svnRoot=%1
set matlabDir=%2
set logDir=%svnRoot%\%3
set matlabBin=%4
set runMarker=%5
set confName=%6

REM Matlab settings
set mDir=%svnRoot%\%matlabDir%
set deploymentDir=%mDir%
if defined confName (
	set mFile=elltool.test.run_tests_remotely('%runMarker%','%confName%')
) else (
	set mFile=elltool.test.run_tests_remotely('%runMarker%')
)

call %~dp0update_svn.bat %svnRoot%

if %ERRORLEVEL% NEQ 0 (
	echo %0: update failed 1>&2
	exit /b 1
)

set myTime=%time:~0,2%-%time:~3,2%-%time:~6,2%
if "%myTime:~0,1%" EQU " " (
	set myTime=0%myTime:~1,7%
)
set myDate=%date:~10,4%-%date:~4,2%-%date:~7,2%

echo %0: Launching Matlab...
MATLAB "%matlabBin%" -sd "%mDir%" -singleCompThread ^
 -logfile %logDir%\run_tests_remotely.%runMarker%.%myDate%_%myTime%.log ^
 -wait -r "try, cd %deploymentDir%, s_install, cd %svnRoot%, %mFile%, exit, catch, exit, end"

echo ==== %0: %date% %time% Done! =====
