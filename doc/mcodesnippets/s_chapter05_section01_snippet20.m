% ellipsoidal approximations for (E1 + E2 - E3)
EL = [E1 E2];
EA = EL.minkpm_ea(E3, L)  % external

% EA =
% 1x4 array of ellipsoids.

IA = EL.minkpm_ia(E3, L)  % internal

% IA =
% 1x3 array of ellipsoids.

E1.minkpm(E2, E3);  % plot the set (E1 + E2 - E3)
