% ellipsoidal approximations for (firstEll + secEll - thirdEll)
bufEllArr = [firstEll secEll];
externalEllArr = bufEllArr.minkpm_ea(thirdEll, dirsMat)  % external

% externalEllArr =
% 1x5 array of ellipsoids.

internalEllArr = bufEllArr.minkpm_ia(thirdEll, dirsMat)  % internal

% internalEllArr =
% 1x4 array of ellipsoids.

% plot the set (firstEll + secEll - thirdEll)
firstEll.minkpm(secEll, thirdEll);  
