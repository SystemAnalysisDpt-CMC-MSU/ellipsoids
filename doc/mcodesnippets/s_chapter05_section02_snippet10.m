ell = ellipsoid([-17; 0], [4 -1; -1 1]);  % define ellipsoid
% define 4 hyperplanes
hypArr = hyperplane([1 1; -1 -1; 1 -1; -1 1]', [2 2 2 2]);  
pol = hyperplane2polytope(hypArr) + [2; 10];  % define polytope
% check if ellipsoid ell intersects with external approximation:
cutObj.intersect(ell, 'e')

% ans =
% 
%      1