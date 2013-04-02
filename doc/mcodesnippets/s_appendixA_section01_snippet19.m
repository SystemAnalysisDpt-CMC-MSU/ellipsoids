firstEllObj = ellipsoid([-2; -1], [4 -1; -1 1]);
secEllObj = ell_unitball(2);
ellVec = [firstEllObj secEllObj firstEllObj.inv];
dirsMat = [1 0; 1 1; 0 1; -1 1]';
externalEllVec = ellVec.minksum_ea(dirsMat)

% externalEllVec =
% 1x4 array of ellipsoids.