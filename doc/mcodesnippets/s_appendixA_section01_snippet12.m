E1 = ellipsoid([-2; -1], [4 -1; -1 1]);
E2 = E1 + [5; 5];
isinternal([E1 E2], [-2 3; -1 4], 'i')

% ans =
% 
%      0     0

isinternal([E1 E2], [-2 3; -1 4])

% ans =
% 
%      1     1