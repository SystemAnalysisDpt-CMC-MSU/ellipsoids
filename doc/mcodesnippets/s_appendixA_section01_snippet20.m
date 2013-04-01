firstEll = ellipsoid([-2; -1], [4 -1; -1 1]);
secEll = ell_unitball(2);
ellArr = [firstEll secEll firstEll.inv];
dirsMat = [1 0; 1 1; 0 1; -1 1]';
internalEllArr = ellArr.minksum_ia(dirsMat)

% internalEllArr =
% 1x4 array of ellipsoids.