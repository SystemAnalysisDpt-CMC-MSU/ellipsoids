E = ellipsoid([-17; 0], [4 -1; -1 1]);  % define ellipsoid
HH = hyperplane([1 1; -1 -1; 1 -1; -1 1]', [2 2 2 2]);  % define 4 hyperplanes
P = hyperplane2polytope(HH) + [2; 10];  % define polytope
% check if ellipsoid E intersects with external approximation:
intersect(ct, E, 'e')

% ans =
% 
%      1