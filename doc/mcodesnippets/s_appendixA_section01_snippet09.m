firstEllObj = ellipsoid([-2; -1], [4 -1; -1 1]);
secEllObj = firstEllObj + [5; 5];
ellVec = [firstEllObj secEllObj];
thirdEllObj  = ell_unitball(2);
internalEllVec = ellVec.intersection_ia(thirdEllObj)

% internalEllVec =
% 1x2 array of ellipsoids.
