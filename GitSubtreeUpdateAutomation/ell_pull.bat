git checkout ellmaster
git clean -f -d -e ell_* pathdef.m
git pull
git branch -D ellmodlib
git subtree split -P lib --rejoin -b ellmodlib
git checkout master
git clean -f -d -e ell_* pathdef.m
git pull
git subtree merge -P externals/ellmodlib --squash ellmodlib

