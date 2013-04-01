firstEll = ellipsoid([-2; -1], [4 -1; -1 1]);
secEll = firstEll + [5; 5];
ellArr = [firstEll secEll];
thirdEll  = ell_unitball(2);
externalEllArr = ellArr.intersection_ea(thirdEll)

% externalEllArr =
% 1x2 array of ellipsoids.
