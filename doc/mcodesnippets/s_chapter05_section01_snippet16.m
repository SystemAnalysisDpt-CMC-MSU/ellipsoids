% define the set of directions:
% columns of matrix dirsMat are vectors in R^2
dirsMat = [1 0; 1 1; 0 1; -1 1; 1 3]';
% compute external ellipsoids for the directions in dirsMat
externalEllVec = ellMat.minksum_ea(dirsMat) 

% externalEllVec =
% Array of ellipsoids with dimensionality 1x5

% compute internal ellipsoids for the directions in dirsMat
internalEllVec = ellMat.minksum_ia(dirsMat)  

% internalEllVec =
% Array of ellipsoids with dimensionality 1x5

% intersection of external ellipsoids should always contain 
% the union of internal ellipsoids:
externalEllVec.doesIntersectionContain(internalEllVec, 'u') 
% 
% ans =
% 
%      1
