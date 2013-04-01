% create two 4-dimensional ellipsoids:
firstEll = ellipsoid([14 -4 2 -5; -4 6 0 1; 2 0 6 -1; -5 1 -1 2]);
secEll = firstEll.inv;

% specify 3-dimensional subspace by its basis:

% columns of basisMat must be orthogonal
basisMat = [1 0 0 0; 0 0 1 0; 0 1 0 1]'; 

% get 3-dimensional projections of firstEll and secEll:
bufEllArr = [firstEll secEll];
% array ellArr contains projections of firstEll and secEll
ellArr = bufEllArr.projection(basisMat)  

% ellArr =
% 1x2 array of ellipsoids.

ellArr.plot;  % plot ellipsoids in ellArr
