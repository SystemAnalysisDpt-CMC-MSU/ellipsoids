firstHypObj = hyperplane([-1; 1]);
secHypObj = hyperplane([-1; 1; 8; -2; 3], 7);
thirdHypObj = hyperplane([1; 2; 0], -1);
[secHypObj firstHypObj thirdHypObj] == [firstHypObj secHypObj thirdHypObj]

% ans =
% 
%      0     0     1
