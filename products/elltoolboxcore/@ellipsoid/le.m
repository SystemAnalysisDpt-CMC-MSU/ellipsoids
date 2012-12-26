function isPositiveArr = le(fstEllArr, secEllArr)
%
% LE - checks if the second ellipsoid is bigger than the first one.
%      Same as LT.
%
% Input:
%   regular:
%       fstEllArr: ellipsoid [nDims1,nDims2,...,nDimsN] - array of ellipsoids.
%       secEllArr: ellipsoid [nDims1,nDims2,...,nDimsN] - array of ellipsoids
%           of the corresponding dimensions.
%
% Output:
%   isPositiveArr: logical[nDims1,nDims2,...,nDimsN],
%       isPositive(iCount) = true - if secEllArr(iCount)
%       contains fstEllArr(iCount)
%       when both have same center, false - otherwise.
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $

isPositiveArr = lt(fstEllArr, secEllArr);
