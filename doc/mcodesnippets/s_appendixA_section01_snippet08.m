firstEllObj = ellipsoid([-2; -1], [4 -1; -1 1]);
secEllObj = firstEllObj + [5; 5];
ellVec = [firstEllObj secEllObj];
thirdEllObj  = ell_unitball(2);
externalEllVec = ellVec.intersection_ea(thirdEllObj)

% externalEllVec =
% 1x2 array of ellipsoids.
