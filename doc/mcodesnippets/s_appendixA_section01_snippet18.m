firstEll = ellipsoid([2; -1], [9 -5; -5 4]);
secEll = ellipsoid([-2; -1], [4 -1; -1 1]);
thirdEll = ell_unitball(2);
ellArr = [thirdEll firstEll];
dirsMat = [1 0; 1 1; 0 1; -1 1]';
internalEllArr = ellArr.minkpm_ia(secEll, dirsMat)

% internalEllArr =
% 1x3 array of ellipsoids.