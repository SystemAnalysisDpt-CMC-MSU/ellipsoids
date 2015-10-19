setlocal
:: Runs a specified Matlab command
::
:: Parameters:
:: 1. deploymentDir - string: name of deployment directory from where s_install script is called
:: 2. matlabBin - string: Matlab program path
:: 3. matlabCmd - string: name of Matlab function to run

set deploymentDir=%1
set matlabBin=%2
set matlabCmd=%~3

echo %0: Launching Matlab from %matlabBin%
cd %deploymentDir%
%matlabBin% -logfile matlab_cmwin_output.log -nodesktop -nosplash -singleCompThread -r "try, s_install, cd .., %matlabCmd%, exit(0), catch meObj, disp(meObj.getReport()), exit(1), end"
echo ==== %0: %date% %time% Done! =====