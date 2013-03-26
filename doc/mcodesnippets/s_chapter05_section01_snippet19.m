% ellipsoidal approximations for (E1 - E3 + E2)
EA = E1.minkmp_ea(E3, E2, L)  % external
% EA =
% 1x4 array of ellipsoids.
IA = E1.minkmp_ia(E3, E2, L)  % internal
% IA =
% 1x4 array of ellipsoids.
E1.minkmp(E3, E2);  % plot the set (E1 - E3 + E2)
