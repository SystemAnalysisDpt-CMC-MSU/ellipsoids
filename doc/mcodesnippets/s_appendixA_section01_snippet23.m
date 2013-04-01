ell = ellipsoid([-2; -1], [4 -1; -1 1]);
mat = [0 1; -1 0];
outEll = mat*ell

% outEll =
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