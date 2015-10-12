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
if [ $# -eq 1 ]
then
	isDesktopUsed=true
else
	isDesktopUsed=$2
fi
echo isDesktopUsed=$isDesktopUsed
#
installDir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
cd $installDir
echo "starting matlab from $installDir"
if $isDesktopUsed
then
	matlabArg="-desktop"
else
	matlabArg="-nodesktop -nosplash"
fi
echo matlabArg=$matlabArg	
$matlabBin $matlabArg -singleCompThread -r "s_install, cd .. "
