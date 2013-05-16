% define the set of directions:
% columns of matrix dirsMat are vectors in R^2
dirsMat = [1 0; 1 1; 0 1; -1 1; 1 3]';
% compute external ellipsoids for the directions in dirsMat
externalEllVec = ellMat.minksum_ea(dirsMat) 

% externalEllVec =
% 1x5 array of ellipsoids.

% compute internal ellipsoids for the directions in dirsMat
internalEllVec = ellMat.minksum_ia(dirsMat)  

% internalEllVec =
% 1x5 array of ellipsoids.

% intersection of external ellipsoids should always contain 
% the union of internal ellipsoids:
externalEllVec.isContainedInIntersection(internalEllVec, 'u') 
% 
% ans =
% 
%      1
