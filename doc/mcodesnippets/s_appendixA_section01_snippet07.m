E1 = ellipsoid([-2; -1], [4 -1; -1 1]);
E2 = E1 + [5; 5];
H  = hyperplane([1; -1]);
intersect([E1 E2], H)

% ans =
% 
%      1

intersect([E1 E2], H, 'i')

% ans =
% 
%     -1
