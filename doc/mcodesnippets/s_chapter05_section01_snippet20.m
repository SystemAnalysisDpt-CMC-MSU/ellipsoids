% ellipsoidal approximations for (E1 + E2 - E3)
EA = minkpm_ea([E1 E2], E3, L)  % external

% EA =
% 1x5 array of ellipsoids.

IA = minkpm_ia([E1 E2], E3, L)  % internal

% IA =
% 1x4 array of ellipsoids.

minkpm(E1, E2, E3);  % plot the set (E1 + E2 - E3)
