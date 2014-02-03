@echo off
setlocal
:: Runs all Matlab unit tests for the latest SVN revision and e-mails results

echo ===== run_tests_remotely started: %date% %time% =====

set gitRoot=C:\GIT_Local\ellipsoids_master
set matlabDir=install
set logDir=automation\log
set matlabBin="C:\Program Files (x86)\MATLAB\R2012a\bin"
set runMarker=master
call %~dp0run_matlab_tests.bat %gitRoot% %matlabDir% %logDir% %matlabBin% %runMarker%
