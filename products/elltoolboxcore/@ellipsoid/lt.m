function isPositiveMat = lt(fstEllMat, secEllMat)
%
% LT - checks if the second ellipsoid is bigger than the first one.
%      The opposite of GT.
%
% Input:
%   regular:
%       fstEllMat: ellipsoid [mRows, nCols] - matrix of ellipsoids.
%       secEllMat: ellipsoid [mRows, nCols] - matrix of ellipsoids
%           of the corresponding dimensions.
%
% Output:
%   isPositiveMat: logical[mRows, nCols],
%       resMat(iRows, jCols) = true - if secEllMat(iRows, jCols)
%       contains fstEllMat(iRows, jCols)
%       when both have same center, false - otherwise.
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $

isPositiveMat = gt(secEllMat, fstEllMat);
