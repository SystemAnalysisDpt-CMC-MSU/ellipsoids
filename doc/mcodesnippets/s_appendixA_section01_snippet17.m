firstEll = ellipsoid([2; -1], [9 -5; -5 4]);
secEll = ellipsoid([-2; -1], [4 -1; -1 1]);
thirdEll = ell_unitball(2);
dirsMat = [1 0; 1 1; 0 1; -1 1]';
ellArr = [thirdEll firstEll];
externalEllArr = ellArr.minkpm_ea(secEll, dirsMat)

% externalEllArr =
% 1x4 array of ellipsoids.