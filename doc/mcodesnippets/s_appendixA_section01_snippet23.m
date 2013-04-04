ellObj = ellipsoid([-2; -1], [4 -1; -1 1]);
tempMat = [0 1; -1 0];
outEllObj = tempMat*ellObj

% outEllObj =
% 
% Center:
%     -1
%      2
% 
% Shape:
%      1     1
%      1     4
% 
% Nondegenerate ellipsoid in R^2.