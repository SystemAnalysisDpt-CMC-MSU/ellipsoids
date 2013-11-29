% compute external and internal ellipsoidal approximations
% of the intersections of ellipsoids in the first column of ellMat
% with the halfspace x1 - x2 <= 2:

% get external ellipsoids
firstExternalEllMat = ellMat(:, 1).intersection_ea(firstHypObj(1))  
% firstExternalEllMat =
% Array of ellipsoids with dimensionality 2x1

% get internal ellipsoids
firstInternalEllMat = ellMat(:, 1).intersection_ia(firstHypObj(1))  
% firstInternalEllMat =
% Array of ellipsoids with dimensionality 2x1

% compute external and internal ellipsoidal approximations
% of the intersections of ellipsoids in the first column of ellMat
% with the halfspace x1 - x2 >= 2:

% get external ellipsoids
secExternalEllMat = ellMat(:, 1).intersection_ea(-firstHypObj(1));
  
% get internal ellipsoids
secInternalEllMat = ellMat(:, 1).intersection_ia(-firstHypObj(1));  
% compute ellipsoidal approximations of the intersection
% of ellipsoid firstEll and polytope firstPol:

% get external ellipsoid
externalEllMat = ellMat(:, 1).intersection_ea(firstPolObj);
% get internal ellipsoid
internalEllMat = ellMat(:, 1).intersection_ia(firstPolObj); 