E1 = ellipsoid([-2; -1], [4 -1; -1 1]);
E2 = E1 + [5; 5];
X  = hyperplane([1; -1]);
E = [E1 E2];
E.intersect(X)

% ans =
% 
%      1

E.intersect(X, 'i')

% ans =
% 
%     -1
