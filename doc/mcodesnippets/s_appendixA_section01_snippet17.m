E1 = ellipsoid([2; -1], [9 -5; -5 4]);
E2 = ellipsoid([-2; -1], [4 -1; -1 1]);
B = ell_unitball(2);
L = [1 0; 1 1; 0 1; -1 1]';
EA = minkpm_ea([B E1], E2, L)

% EA =
% 1x4 array of ellipsoids.
