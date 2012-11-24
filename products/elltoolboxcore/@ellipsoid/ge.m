function resMat = ge(firsrEllMat, secondEllMat)
%
% GE - checks if the first ellipsoid is bigger than the second one.
%      Same as GT.
%
% Input:
%   regular:
%       firsrEllMat: ellipsoid [mRows, nCols] - matrix of ellipsoids.
%       secondEllMat: ellipsoid [mRows, nCols] - matrix of ellipsoids
%           of the corresponding dimensions.
%
% Output:
%   resMat: double[mRows, nCols],
%       resMat(iRows, jCols) = 1 - if firsrEllMat(iRows, jCols)
%       contains secondEllMat(iRows, jCols)
%       when both have same center, 0 - otherwise.
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $

resMat = gt(firsrEllMat, secondEllMat);
