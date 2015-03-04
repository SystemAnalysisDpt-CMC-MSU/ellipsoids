@echo off
setlocal
:: Runs all Matlab unit tests for the latest SVN revision and e-mails results

echo ===== run_tests_remotely started: %date% %time% =====
@echo off
setlocal
SET SUBDIR=%~dp0
call :parentfolder %SUBDIR:~0,-1% 
endlocal
goto :eof
:parentfolder
set gitRoot=%~dp1
set matlabDir=install
set logDir=automation\log
set matlabBin="C:\Program Files\MATLAB\R2013b\bin"
set runMarker=master
call %~dp0run_matlab_tests.bat %gitRoot% %matlabDir% %logDir% %matlabBin% %runMarker%
