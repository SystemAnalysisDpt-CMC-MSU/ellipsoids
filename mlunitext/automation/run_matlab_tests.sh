#!/bin/bash
# Runs all Matlab unit tests for the latest GIT revision and e-mails results
#
# Parameters:
# 1. deploymentDir - string: name of deployment directory from where s_install script is called
# 2. matlabFunc - string: name of Matlab function to run
# 3. matlabBin - string: Matlab program path
# 4. runMarker - string: Identifying string for the test
# 5. confName - string: test configuration name (optional)

scriptName=`basename $0` #script name
#scriptDir=`dirname $0` # script directory
#scriptDir=`cd $scriptDir; pwd` # full path to the script directory
scriptDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
#
if [ $# -le 1 ]
then
	echo matlabFunc and deploymentDir are obligatory input arguments
	exit 1
else
	deploymentDir=$1
	matlabFunc=$2
fi	

if [ $# -le 2 ]
then
	matlabBin="matlab"
else
	matlabBin=$3
fi
if [ $# -le 3 ]
then
	runMarker="test"
else
	runMarker=$4
fi
if [ $# -le 4 ]
then
	mFile="$matlabFunc('$runMarker')"
else
	mFile="$matlabFunc('$runMarker','$5')"
fi
	
#
gitRepoRoot="$(dirname "$scriptDir")"
#
echo ==== $scriptName: `date` Started =====
#
cd $deploymentDir
echo $scriptName: Launching Matlab from $matlabBin to execute $mFile
$matlabBin -nodesktop -nosplash -singleCompThread -r "try, s_install, cd .., resVec=$mFile, exit(0), catch meObj, disp(meObj.getReport()), exit(1), end"
echo ==== $scriptName: `date` Done! =====
