function isPositiveArr = ge(firsrEllArr, secondEllArr)
%
% GE - checks if the first ellipsoid is bigger than the second one.
%      Same as GT.
%
% Input:
%   regular:
%       firsrEllArr: ellipsoid [nDims1,nDims2,...,nDimsN]/[1,1] - array 
%           of ellipsoids.
%       secondEllArr: ellipsoid [nDims1,nDims2,...,nDimsN]/[1,1] - array
%           of ellipsoids of the corresponding dimensions.
%
% Output:
%   isPositiveArr: logical [nDims1,nDims2,...,nDimsN],
%       isPositiveArr(iCount) = true - if firsrEllArr(iCount)
%       contains secondEllArr(iCount)
%       when both have same center, false - otherwise.
%
% Example:
%   ellObj = ellipsoid([1 ;2], eye(2))
%   ellObj > ellObj
% 
%   ans =
% 
%        1
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 
%              2004-2008 $

isPositiveArr = gt(firsrEllArr, secondEllArr);
