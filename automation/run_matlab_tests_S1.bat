@echo off
setlocal
:: Runs all Matlab unit tests for the latest SVN revision and e-mails results

echo ===== run_tests_remotely started: %date% %time% =====

set svnRoot=C:\SVN_Local\EllTrunk
set matlabDir=install
set logDir=automation\log
set matlabBin="C:\Program Files (x86)\MATLAB\R2012a\bin"
set runMarker=trunk

call %~dp0run_matlab_tests.bat %svnRoot% %matlabDir% %logDir% %matlabBin% %runMarker%
