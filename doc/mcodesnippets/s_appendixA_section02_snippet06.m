H1 = hyperplane([-1; 1]);
H2 = hyperplane([-1; 1; 8; -2; 3], 7);
H3 = hyperplane([1; 2; 0], -1);
[H2 H1 H3] == [H1 H2 H3]

% ans =
% 
%      0     0     1
