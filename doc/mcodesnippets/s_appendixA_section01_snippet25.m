ellVec  = [ellipsoid([-2; -1], [4 -1; -1 1]) ell_unitball(2)];
outEllVec = ellVec + [1; 1];
outEllVec(1)

% ans =
% 
% Center:
%     -1
%      0
% 
% Shape:
%      4    -1
%     -1     1
% 
% Nondegenerate ellipsoid in R^2.

outEllVec(2)
% 
% ans =
% 
% Center:
%      1
%      1
% 
% Shape:
%      1     0
%      0     1
% 
% Nondegenerate ellipsoid in R^2.