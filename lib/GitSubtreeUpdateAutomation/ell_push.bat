git checkout master
git clean -f -d
git pull
git branch -D ellmodlib
git subtree split --prefix externals/ellmodlib --ignore-joins -b ellmodlib
git fetch ellipsoids
git checkout -B ellmaster ellipsoids/master
git clean -f -d
git pull
git subtree merge -P lib --squash ellmodlib

