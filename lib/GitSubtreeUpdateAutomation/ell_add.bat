git checkout master
git clean -f -d -e "ell_*" pathdef.m
git pull
git remote add -f ellipsoids https://github.com/SystemAnalysisDpt-CMC-MSU/ellipsoids.git
git checkout -B ellmaster ellipsoids/master
git clean -f -d -e "ell_*" pathdef.m
git subtree split -P lib --rejoin -b ellmodlib
git checkout master
git clean -f -d -e "ell_*" pathdef.m
git subtree add -P externals/ellmodlib --squash ellmodlib
