aMat = [0 1; -2 0];  % aMat - 2x2 real matrix
bVec = [3; 0]; % bVec - vector in R^2
% affine transformation of ellipsoids in the second column of ellMat
aTransMat = aMat * ellMat(:, 2) + bVec;  
