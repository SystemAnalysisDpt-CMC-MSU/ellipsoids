% ellipsoidal approximations for (firstEllObj + secEllObj - thirdEllObj)
bufEllVec = [firstEllObj secEllObj];
externalEllVec = bufEllVec.minkpm_ea(thirdEllObj, dirsMat)  % external

% externalEllVec =
% 1x5 array of ellipsoids.

internalEllVec = bufEllVec.minkpm_ia(thirdEllObj, dirsMat)  % internal

% internalEllVec =
% 1x4 array of ellipsoids.

% plot the set (firstEllObj + secEllObj - thirdEllObj)
firstEllObj.minkpm(secEllObj, thirdEllObj);  
