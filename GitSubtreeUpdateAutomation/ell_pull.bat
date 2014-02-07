git checkout -B ellmaster ellipsoids/master
git clean -f -d
git pull
git branch -D ellmodlib
git subtree split -P lib --ignore-joins -b ellmodlib
git checkout master
git clean -f -d
git pull
git subtree merge -P externals/ellmodlib --squash ellmodlib

