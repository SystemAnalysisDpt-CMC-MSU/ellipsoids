E1 = ellipsoid([-2; -1], [4 -1; -1 1]);
E2 = E1 + [5; 5];
E = [E1 E2];
E.isinternal([-2 3; -1 4], 'i')

% ans =
% 
%      0     0

E.isinternal([-2 3; -1 4])

% ans =
% 
%      1     1