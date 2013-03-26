E1 = ellipsoid([-2; -1], [4 -1; -1 1]);
E2 = E1 + [5; 5];
H  = hyperplane([1; -1]);
E = [E1 E2];
E.intersect(H)

% ans =
% 
%      1

E.intersect(H, 'i')

% ans =
% 
%     -1
