% define the set of directions:
% columns of matrix dirsMat are vectors in R^2
dirsMat = [1 0; 1 1; 0 1; -1 1; 1 3]';
% compute external ellipsoids for the directions in dirsMat
externalEllArr = ellArr.minksum_ea(dirsMat) 

% externalEllArr =
% 1x5 array of ellipsoids.

% compute internal ellipsoids for the directions in dirsMat
internalEllArr = ellArr.minksum_ia(dirsMat)  

% internalEllArr =
% 1x5 array of ellipsoids.

% intersection of external ellipsoids should always contain 
% the union of internal ellipsoids:
externalEllArr.isinside(internalEllArr, 'u') 
% 
% ans =
% 
%      1
