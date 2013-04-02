firstEllObj = ellipsoid([2; -1], [9 -5; -5 4]);
secEllObj = ellipsoid([-2; -1], [4 -1; -1 1]);
thirdEllObj = ell_unitball(2);
dirsMat = [1 0; 1 1; 0 1; -1 1]';
ellVec = [thirdEllObj firstEllObj];
externalEllVec = ellVec.minkpm_ea(secEllObj, dirsMat)

% externalEllVec =
% 1x4 array of ellipsoids.