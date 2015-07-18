setlocal
:: Runs all Matlab unit tests for the latest GIT revision and e-mails results
::
:: Parameters:
:: 1. deploymentDir - string: name of deployment directory from where s_install script is called
:: 2. matlabCmd - string: name of Matlab function to run
:: 3. matlabBin - string: Matlab program path

set deploymentDir=%1
set matlabBin=%2
set matlabCmd=%~3

echo %0: Launching Matlab from %matlabBin%
cd %deploymentDir%
%matlabBin% -nodesktop -nosplash -singleCompThread -r "try, s_install, cd .., %matlabCmd%, exit(0), catch meObj, disp(meObj.getReport()), exit(1), end"
echo ==== %0: %date% %time% Done! =====