% ellipsoidal approximations for (firstEllObj - thirdEllObj + secEllObj)

% external
externalEllVec = firstEllObj.minkmp_ea(thirdEllObj, secEllObj, dirsMat) 
% externalEllVec =
% 1x5 array of ellipsoids.

% internal
internalEllVec = firstEllObj.minkmp_ia(thirdEllObj, secEllObj, dirsMat)
% internalEllVec =
% 1x5 array of ellipsoids.

% plot the set (firstEllObj - thirdEllObj + secEllObj)
firstEllObj.minkmp(thirdEllObj, secEllObj);
