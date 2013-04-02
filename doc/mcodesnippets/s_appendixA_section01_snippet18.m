firstEllObj = ellipsoid([2; -1], [9 -5; -5 4]);
secEllObj = ellipsoid([-2; -1], [4 -1; -1 1]);
thirdEllObj = ell_unitball(2);
ellVec = [thirdEllObj firstEllObj];
dirsMat = [1 0; 1 1; 0 1; -1 1]';
internalEllVec = ellVec.minkpm_ia(secEllObj, dirsMat)

% internalEllVec =
% 1x3 array of ellipsoids.