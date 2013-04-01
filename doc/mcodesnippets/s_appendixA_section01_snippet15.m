firstEll = ellipsoid([-2; -1], [4 -1; -1 1]);
secEll = 3*ell_unitball(2);
dirsMat = [1 0; 1 1; 0 1; -1 1]';
externalEllArr = secEll.minkmp_ea(firstEll, [secEll firstEll], dirsMat)

% externalEllArr =
% 1x2 array of ellipsoids.
