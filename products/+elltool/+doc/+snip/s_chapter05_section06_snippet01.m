% create two 4-dimensional ellipsoids:
firstEllObj = ellipsoid([14 -4 2 -5; -4 6 0 1; 2 0 6 -1; -5 1 -1 2]);
secEllObj = firstEllObj.getInv();

% specify 3-dimensional subspace by its basis:

% columns of basisMat must be orthogonal
basisMat = [1 0 0 0; 0 0 1 0; 0 1 0 1].'; 

% get 3-dimensional projections of firstEllObj and secEllObj:
bufEllVec = [firstEllObj secEllObj];
% array ellVec contains projections of firstEllObj and secEllObj
ellVec = bufEllVec.projection(basisMat)  

% ellVec =
% Array of ellipsoids with dimensionality 1x2

ellVec.plot();  % plot ellipsoids in ellVec
