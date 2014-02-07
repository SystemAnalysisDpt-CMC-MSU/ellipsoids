git checkout master
git clean -f -d
git pull
git remote add -f ellipsoids https://github.com/SystemAnalysisDpt-CMC-MSU/ellipsoids.git
git checkout -B ellmaster ellipsoids/master
git clean -f -d
git subtree split -P lib --ignore-joins -b ellmodlib
git checkout master
git clean -f -d
git subtree add -P externals/ellmodlib --squash ellmodlib
