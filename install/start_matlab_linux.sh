#!/bin/bash
if [ $# -eq 0 ]
then
	matlabBin='matlab'
	matlabLoc=$(whereis matlab)
	echo "Running matlab using this script: $matlabLoc"
else
	matlabBin=$1
	echo "Running matlab from $matlabBin"
fi
#
installDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
cd $installDir
echo "starting matlab from $installDir"
$matlabBin -desktop -singleCompThread -r "s_install, cd .. "&
