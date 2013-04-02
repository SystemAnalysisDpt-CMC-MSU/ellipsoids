E = ellipsoid([-2; -1], [4 -1; -1 1]);
B = 3*ell_unitball(2);
L = [1 0; 1 1; 0 1; -1 1]';
IA = minkdiff_ia(B, E, L)

% IA =
% 1x2 array of ellipsoids.
