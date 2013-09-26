% ellipsoidal approximations for (firstEllObj + secEllObj - thirdEllObj)
bufEllVec = [firstEllObj secEllObj];
externalEllVec = bufEllVec.minkpm_ea(thirdEllObj, dirsMat)  % external

% externalEllVec =
% Array of ellipsoids with dimensionality 1x5

internalEllVec = bufEllVec.minkpm_ia(thirdEllObj, dirsMat)  % internal

% internalEllVec =
% Array of ellipsoids with dimensionality 1x4

% plot the set (firstEllObj + secEllObj - thirdEllObj)
firstEllObj.minkpm(secEllObj, thirdEllObj)
