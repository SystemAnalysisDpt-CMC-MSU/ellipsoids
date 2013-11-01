function [isNeqArr, reportStr] = ne(ellFirstArr, ellSecArr)
% NE - the opposite of EQ
%
% Input:
%   regular:
%       ellFirstArr: ellipsoid: [nDims1,nDims2,...,nDimsN]/[1,1]- the first
%           array of ellipsoid objects
%       ellSecArr: ellipsoid: [nDims1,nDims2,...,nDimsN]/[1,1] - the second
%           array of ellipsoid objects
%
% Output:
%   isNeqArr: logical: [nDims1,nDims2,...,nDimsN]- array of comparison
%       results
%
%   reportStr: char[1,] - comparison report
%
% Example:
%   ellObj = ellipsoid([-2; -1], [4 -1; -1 1]);
%   ellObj ~= [ellObj ellipsoid(eye(2))]
% 
%   ans =
% 
%       0     1
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 
%              2004-2008 $

[isEqualArr, reportStr] = isEqual(ellFirstArr, ellSecArr);
isNeqArr = ~isEqualArr;