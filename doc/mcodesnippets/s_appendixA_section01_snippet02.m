ellObj = ellipsoid([-2; -1], [4 -1; -1 1]);
tempMat = [1 1; 1 -1; -1 1; -1 -1]';
distVec = ellObj.distance(tempMat)

% distVec =
% 
%      2.3428    1.0855    1.3799    -1.0000