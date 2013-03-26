H = hyperplane([-1; 1]);
X = [100 -1 2; 100 1 2];
H.contains(X)

% ans =
% 
%      1
%      0
%      1