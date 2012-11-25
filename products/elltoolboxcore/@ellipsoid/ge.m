function isPositiveMat = ge(firsrEllMat, secondEllMat)
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
%   isPositiveMat: logical[mRows, nCols],
%       resMat(iRows, jCols) = true - if firsrEllMat(iRows, jCols)
%       contains secondEllMat(iRows, jCols)
%       when both have same center, false - otherwise.
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $

isPositiveMat = gt(firsrEllMat, secondEllMat);
