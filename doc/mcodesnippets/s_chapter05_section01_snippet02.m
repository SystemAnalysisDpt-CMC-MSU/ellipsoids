E1 = ellipsoid([2; -1], [9 -5; -5 4]);  % nondegenerate ellipsoid in R^2
E2 = E1.polar;  % E2 is polar ellipsoid for E1
E3 = E2.inv;  % E3 is generated from E2 by inverting its shape matrix
EE = [E1 E2; E3 ellipsoid([1; 1], eye(2))];  % 2x2 array of ellipsoids
EE <= E1  % check if E1 is bigger than each of the ellipsoids in EE

% ans =
% 
%      1     0
%      1     0
