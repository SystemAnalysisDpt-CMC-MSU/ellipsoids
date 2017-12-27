#!/bin/bash
export curDir=$PWD


export locDir=`dirname $0`

rm -rf $locDir/../../../doc/docs
cp -f "$locDir/README.md" "$locDir/../../../README.md"

python $locDir/prep4doxymat.py $locDir/../..  $locDir/../../../TTD/elltool-doxygen-prep   $locDir/../../../TTD/elltool-doxygen-garbage

cd $locDir
doxygen

echo "">../../../doc/docs/.nojekyll
cd $curDir


exit 0
