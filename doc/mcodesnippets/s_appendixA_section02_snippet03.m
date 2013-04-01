firstHyp = hyperplane([-1; 1]);
secHyp = hyperplane([-1; 1; 8; -2; 3], 7);
thirdHyp = hyperplane([1; 2; 0], -1);
secHyp == [firstHyp secHyp thirdHyp]

% ans =
% 
%      0     1     0