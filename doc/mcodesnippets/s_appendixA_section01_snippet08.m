E1 = ellipsoid([-2; -1], [4 -1; -1 1]);
E2 = E1 + [5; 5];
E = [E1 E2];
B  = ell_unitball(2);
EA = E.intersection_ea(B)

% EA =
% 1x2 array of ellipsoids.
