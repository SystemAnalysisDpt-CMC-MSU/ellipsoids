ellObj = ellipsoid([-2; -1], [4 -1; -1 1]);
tempMat = [0 1; -1 0];
outEllObj = shape(ellObj, tempMat)

% outEllObj =
% 
% Center:
%     -2
%     -1
% 
% Shape:
%      1     1
%      1     4
% 
% Nondegenerate ellipsoid in R^2.