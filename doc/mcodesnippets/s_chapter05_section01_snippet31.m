% compute external and internal ellipsoidal approximations
% of the intersections of ellipsoids in the first column of ellArr
% with the halfspace x1 - x2 <= 2:

% get external ellipsoids
firstExternalEllArr = ellArr(:, 1).intersection_ea(firstHyp(1))  
% firstExternalEllArr =
% 2x1 array of ellipsoids.

% get internal ellipsoids
firstInternalEllArr = ellArr(:, 1).intersection_ia(firstHyp(1))  
% firstInternalEllArr =
% 2x1 array of ellipsoids.

% compute external and internal ellipsoidal approximations
% of the intersections of ellipsoids in the first column of EE
% with the halfspace x1 - x2 >= 2:

% get external ellipsoids
secExternalEllArr = ellArr(:, 1).intersection_ea(-firstHyp(1));
  
% get internal ellipsoids
secInternalEllArr = ellArr(:, 1).intersection_ia(-firstHyp(1));  
% compute ellipsoidal approximations of the intersection
% of ellipsoid firstEll and polytope firstPol:

% get external ellipsoid
externalEllArr = ellArr(:, 1).intersection_ea(firstPol);
% get internal ellipsoid
internalEllArr = ellArr(:, 1).intersection_ia(firstPol); 