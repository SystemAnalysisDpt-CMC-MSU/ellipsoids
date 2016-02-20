#!/bin/bash
# Runs a specified Matlab command
#
# Parameters:
# 1. deploymentDir - string: name of deployment directory from where s_install script is called
# 2. matlabBin - string: Matlab program path
# 3. matlabCmd - string: name of Matlab function to run

scriptName=`basename $0` #script name
#
deploymentDir=$1
matlabBin=$2
matlabCmd=$3

#
echo ==== $scriptName: `date` Started =====
#
if $MATLINQ_RUN_TEST_WITH_DESKTOP
then
	echo running in Desktop mode
	matlabArg="-desktop"
else
	echo running in NoDesktop mode
	matlabArg="-nodesktop"
fi

cd $deploymentDir
echo $scriptName: Launching Matlab from $matlabBin to execute $mFile
$matlabBin $matlabArg  -logfile matlab_cmwin_output.log -nosplash -singleCompThread -r "try, s_install, cd .., $matlabCmd, exit(0), catch meObj, disp(meObj.getReport()), exit(1), end"
echo ==== $scriptName: `date` Done! =====
