% compute external and internal ellipsoidal approximations
% of the intersections of ellipsoids in the first column of EE
% with the halfspace x1 - x2 <= 2:
EA1 = EE(:, 1).intersection_ea(H(1))  % get external ellipsoids
% EA1 =
% 2x1 array of ellipsoids.
IA1 = EE(:, 1).intersection_ia(H(1))  % get internal ellipsoids
% IA1 =
% 2x1 array of ellipsoids.

% compute external and internal ellipsoidal approximations
% of the intersections of ellipsoids in the first column of EE
% with the halfspace x1 - x2 >= 2:
EA2 = EE(:, 1).intersection_ea(-H(1));  % get external ellipsoids
IA2 = EE(:, 1).intersection_ia(-H(1));  % get internal ellipsoids
% compute ellipsoidal approximations of the intersection
% of ellipsoid E1 and polytope P:
EA = EE(:, 1).intersection_ea(P);  % get external ellipsoid
IA = EE(:, 1).intersection_ia(P);  % get internal ellipsoid