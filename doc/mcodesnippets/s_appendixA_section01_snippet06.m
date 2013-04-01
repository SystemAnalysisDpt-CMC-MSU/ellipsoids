ell = ellipsoid([-2; -1], [4 -1; -1 1]);
hypArr = [hyperplane([0 -1; -1 0]', 1); hyperplane([0 -2; -1 0]', 1)]
ellMat = ell.hpintersection(hypArr)

% ellMat =
% 2x2 array of ellipsoids.
