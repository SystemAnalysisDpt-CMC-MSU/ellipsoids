% compute external and internal ellipsoidal approximations
% of the intersections of ellipsoids in the first column of EE
% with the halfspace x1 - x2 <= 2:
EA1 = intersection_ea(EE(:, 1), H(1))  % get external ellipsoids
% EA1 =
% 2x1 array of ellipsoids.
IA1 = intersection_ia(EE(:, 1), H(1))  % get internal ellipsoids
% IA1 =
% 2x1 array of ellipsoids.

% compute external and internal ellipsoidal approximations
% of the intersections of ellipsoids in the first column of EE
% with the halfspace x1 - x2 >= 2:
EA2 = intersection_ea(EE(:, 1), -H(1));  % get external ellipsoids
IA2 = intersection_ia(EE(:, 1), -H(1));  % get internal ellipsoids
% compute ellipsoidal approximations of the intersection
% of ellipsoid E1 and polytope P:
EA = intersection_ea(E1, P);  % get external ellipsoid
IA = intersection_ia(E1, P);  % get internal ellipsoid

