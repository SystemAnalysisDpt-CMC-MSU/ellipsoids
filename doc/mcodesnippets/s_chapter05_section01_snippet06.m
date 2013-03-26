D = ellipsoid([42 -7 -2 4; -7 10 3 1; -2 3 5 -2; 4 1 -2 2]);  % define new ellipsoid
EL = [EE(1, :) D];
EL.isdegenerate  % check if given ellipsoids are degenerate

% ans =
% 
%      0     0     1