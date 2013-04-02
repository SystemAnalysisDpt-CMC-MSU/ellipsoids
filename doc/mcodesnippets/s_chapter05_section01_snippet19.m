% ellipsoidal approximations for (E1 - E3 + E2)
EA = minkmp_ea(E1, E3, E2, L)  % external
% EA =
% 1x5 array of ellipsoids.
IA = minkmp_ia(E1, E3, E2, L)  % internal
% IA =
% 1x5 array of ellipsoids.
minkmp(E1, E3, E2);  % plot the set (E1 - E3 + E2)
