ellObj = ellipsoid([-17; 0], [4 -1; -1 1]);  % define ellipsoid
% define 4 hyperplanes
hypVec = hyperplane([1 1; -1 -1; 1 -1; -1 1]', [2 2 2 2]); 
polObj = hyperplane2polytope(hypVec) + [2; 10];  % define polytope
% check if ellipsoid ell intersects with external approximation:
cutObj.intersect(ellObj, 'e')

% ans =
% 
%      1