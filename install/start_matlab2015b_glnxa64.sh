#!/bin/bash
# Runs all Matlab unit tests for the latest SVN revision and e-mails results
scriptName=`basename $0` #script name
#scriptDir=`dirname $0` # script directory
scriptDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
#matlabBin=/usr/local/MATLAB/R2015b/bin/matlab
matlabBin=/Applications/MATLAB_R2015b.app/bin/matlab
$scriptDir/start_matlab_linux.sh $matlabBin "${@}"
