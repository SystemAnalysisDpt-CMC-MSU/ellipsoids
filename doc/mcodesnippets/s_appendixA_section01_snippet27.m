E = ellipsoid([-2; -1; 4], [4 -1 0; -1 1 0; 0 0 9]);
B = [0 1 0; 0 0 1]';
P = E.projection(B)

% P =
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