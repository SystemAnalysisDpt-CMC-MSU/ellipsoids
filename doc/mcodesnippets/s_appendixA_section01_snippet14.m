firstEll = ellipsoid([-2; -1], [4 -1; -1 1]);
secEll = 3*ell_unitball(2);
dirsMat = [1 0; 1 1; 0 1; -1 1]';
internalEllArr = secEll.minkdiff_ia(firstEll, dirsMat)

% internalEllArr =
% 1x2 array of ellipsoids.
