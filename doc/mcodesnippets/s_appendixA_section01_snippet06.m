ellObj = ellipsoid([-2; -1], [4 -1; -1 1]);
hypMat = [hyperplane([0 -1; -1 0]', 1); hyperplane([0 -2; -1 0]', 1)];
ellMat = ellObj.hpintersection(hypMat)

% ellMat =
% 2x2 array of ellipsoids.
