% define new ellipsoid
fourthEllObj = ellipsoid([42 -7 -2 4; -7 10 3 1; -2 3 5 -2; 4 1 -2 2]);  
bufEllVec = [ellMat(1, :) fourthEllObj];
bufEllVec.isdegenerate() % check if given ellipsoids are degenerate

% ans =
% 
%      0     0     1