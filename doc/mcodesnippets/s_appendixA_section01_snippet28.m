ell = ellipsoid([-2; -1], [4 -1; -1 1]);
mat = [0 1; -1 0];
outEll = shape(ell, mat)

% outEll =
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