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
echo deploymentDir=${deploymentDir}
echo matlabFunc=${matlabFunc}
if [ $# -le 2 ]
then
	matlabBin="matlab"
else
	matlabBin=$3
fi
echo matlabBin=${matlabBin}
if [ $# -le 3 ]
then
	runMarker="test"
else
	runMarker=$4
fi
echo runMarker=${runMarker}
if [ $# -le 4 ]
then
	matlabCmd="$matlabFunc('$runMarker')"
else
	matlabCmd="$matlabFunc('$runMarker','$5')"
fi
#
echo ==== $scriptName: `date` Started =====
#
echo just start and close matlab via $scriptDir/run_matlab_cmd.sh
$scriptDir/run_matlab_cmd.sh $deploymentDir $matlabBin
echo just start matlab and run tests via $scriptDir/run_matlab_cmd.sh
$scriptDir/run_matlab_cmd.sh $deploymentDir $matlabBin "$matlabCmd"
echo ==== $scriptName: `date` Done! =====
