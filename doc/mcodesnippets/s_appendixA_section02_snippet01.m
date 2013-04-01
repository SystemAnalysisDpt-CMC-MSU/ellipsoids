hyp = hyperplane([-1; 1]);
mat = [100 -1 2; 100 1 2];
hyp.contains(mat)

% ans =
% 
%      1
%      0
%      1