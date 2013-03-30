E1 = ellipsoid([2; -1], [9 -5; -5 4]);
E2 = ellipsoid([-2; -1], [4 -1; -1 1]);
B = ell_unitball(2);
EE = [B E1];
L = [1 0; 1 1; 0 1; -1 1]';
IA = E.minkpm_ia(E2, L)

% IA =
% 1x3 array of ellipsoids.