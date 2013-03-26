E = ellipsoid([-2; -1], [4 -1; -1 1]);
B = ell_unitball(2);
L = [1 0; 1 1; 0 1; -1 1]';
IA = minkmp_ia(3*B, E, [B E], L)

% IA =
% 1x2 array of ellipsoids.
