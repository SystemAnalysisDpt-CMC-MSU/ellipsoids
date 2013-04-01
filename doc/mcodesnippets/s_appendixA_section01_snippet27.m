ell = ellipsoid([-2; -1; 4], [4 -1 0; -1 1 0; 0 0 9]);
basisMat = [0 1 0; 0 0 1]';
outEll = ell.projection(basisMat)

% outEll =
% 
% Center:
%     -1
%      4
% 
% Shape:
%      1     0
%      0     9
% 
% Nondegenerate ellipsoid in R^2.