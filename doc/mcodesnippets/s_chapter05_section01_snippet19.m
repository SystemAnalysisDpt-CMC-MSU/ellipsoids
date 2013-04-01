% ellipsoidal approximations for (firstEll - thirdEll + secEll)
externalEllArr = firstEll.minkmp_ea(thirdEll, secEll, dirsMat)  % external
% externalEllArr =
% 1x5 array of ellipsoids.
internalEllArr = firstEll.minkmp_ia(thirdEll, secEll, dirsMat)  % internal
% internalEllArr =
% 1x5 array of ellipsoids.

% plot the set (firstEll - thirdEll + secEll)
firstEll.minkmp(thirdEll, secEll);  
