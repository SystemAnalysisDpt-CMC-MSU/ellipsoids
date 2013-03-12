E = ellipsoid([-2; -1], [4 -1; -1 1]);
B = ell_unitball(2);
L = [1 0; 1 1; 0 1; -1 1]';
IA = minksum_ia([E B inv(E)], L)

% IA =
% 1x4 array of ellipsoids.
