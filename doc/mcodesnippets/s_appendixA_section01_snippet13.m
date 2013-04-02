firstEllObj= ellipsoid([-2; -1], [4 -1; -1 1]);
secEllObj = 3*ell_unitball(2);
dirsMat = [1 0; 1 1; 0 1; -1 1]';
externalEllVec = secEllObj.minkdiff_ea(firstEllObj, dirsMat)

% externalEllVec =
% 1x2 array of ellipsoids.
