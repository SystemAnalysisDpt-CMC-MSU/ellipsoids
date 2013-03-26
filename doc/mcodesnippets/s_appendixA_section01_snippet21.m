E  = [ellipsoid([-2; -1], [4 -1; -1 1]) ell_unitball(2)];
E1 = E - [1; 1];
E1(1)

% ans =
% 
% Center:
%     -3
%     -2
% 
% Shape:
%      4    -1
%     -1     1
% 
% Nondegenerate ellipsoid in R^2.

E1(2)

% ans =
% 
% Center:
%     -1
%     -1
% 
% Shape:
%      1     0
%      0     1
% 
% Nondegenerate ellipsoid in R^2.
