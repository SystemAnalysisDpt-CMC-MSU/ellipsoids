git checkout master
git clean -f -d -e "ell_*" pathdef.m
git pull
git branch -D ellmodlib
git subtree split --prefix externals/ellmodlib --rejoin -b ellmodlib
git checkout ellmaster
git clean -f -d -e "ell_*" pathdef.m
git pull
git subtree merge -P lib --squash ellmodlib

