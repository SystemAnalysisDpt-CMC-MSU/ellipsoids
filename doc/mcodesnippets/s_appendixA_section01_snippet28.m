E = ellipsoid([-2; -1], [4 -1; -1 1]);
A = [0 1; -1 0];
E1 = shape(E, A)

% E1 =
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