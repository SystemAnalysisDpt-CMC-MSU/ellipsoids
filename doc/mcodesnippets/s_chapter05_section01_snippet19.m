% ellipsoidal approximations for (firstEllObj - thirdEllObj + secEllObj)

% external
externalEllVec = firstEllObj.minkmp_ea(thirdEllObj, secEllObj, dirsMat) 
% externalEllVec =
% Array of ellipsoids with dimensionality 1x5

% internal
internalEllVec = firstEllObj.minkmp_ia(thirdEllObj, secEllObj, dirsMat)
% internalEllVec =
% Array of ellipsoids with dimensionality 1x5

% plot the set (firstEllObj - thirdEllObj + secEllObj)
firstEllObj.minkmp(thirdEllObj, secEllObj);
