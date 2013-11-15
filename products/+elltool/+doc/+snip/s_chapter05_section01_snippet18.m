absTol = getAbsTol(firstEllObj);
% find out which of the directions in dirsMat are bad
firstEllObj.isbaddirection(fourthEllObj, dirsMat, absTol)  

% ans =
% 
%      1     0     0     1     0 


% two of five directions specified by dirsMat are bad,
% so, only three ellipsoidal approximations 
% can be produced for this dirsMat:
externalEllVec = firstEllObj.minkdiff_ea(fourthEllObj, dirsMat) 

% externalEllVec =
% Array of ellipsoids with dimensionality 1x3

internalEllVec = firstEllObj.minkdiff_ia(fourthEllObj, dirsMat)

% internalEllVec =
% Array of ellipsoids with dimensionality 1x3