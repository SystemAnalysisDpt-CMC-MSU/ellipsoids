hypObj = hyperplane([-1; 1]);
tempMat = [100 -1 2; 100 1 2];
hypObj.contains(tempMat)

% ans =
% 
%      1
%      0
%      1