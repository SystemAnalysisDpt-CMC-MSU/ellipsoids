E1 = ellipsoid([-2; -1], [4 -1; -1 1]);
E2 = 3*ell_unitball(2);
L = [1 0; 1 1; 0 1; -1 1]';
IA = E2.minkdiff_ia(E1, L)

% IA =
% 1x2 array of ellipsoids.
