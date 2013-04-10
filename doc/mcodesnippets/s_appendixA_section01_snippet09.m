E1 = ellipsoid([-2; -1], [4 -1; -1 1]);
E2 = E1 + [5; 5];
B  = ell_unitball(2);
IA = intersection_ia([E1 E2], B)

% IA =
% 1x2 array of ellipsoids.
