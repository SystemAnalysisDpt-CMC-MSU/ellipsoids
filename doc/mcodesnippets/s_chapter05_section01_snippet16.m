% define the set of directions:
L = [1 0; 1 1; 0 1; -1 1; 1 3]';  % columns of matrix L are vectors in R^2
EA = minksum_ea(EE, L)  % compute external ellipsoids for the directions in L

% EA =
% 1x5 array of ellipsoids.

IA = minksum_ia(EE, L)  % compute internal ellipsoids for the directions in L

% IA =
% 1x5 array of ellipsoids.

isinside(EA, IA, 'u') % intersection of external ellipsoids should always contain
                      % the union of internal ellipsoids:
% 
% ans =
% 
%      1
