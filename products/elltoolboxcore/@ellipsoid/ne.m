function [isNeqArr, reportStr] = ne(ellFirstArr, ellSecArr)
% NE - the opposite of EQ
%
% Input:
%  regular:
%   ellFirstArr: ellipsoid: [nDims1,nDims2,...,nDimsN]/[1,1] 
%                  - the first array of ellipsoid objects
%           
%   ellSecArr: ellipsoid: [nDims1,nDims2,...,nDimsN]/[1,1]
%                  - the secondarray of ellipsoid objects
%
% Output:
%   isNeqArr: logical: [nDims1,nDims2,...,nDimsN]- array of
%                             comparison  results
%       
%
%   reportStr: char[1,] - comparison report
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 
%              2004-2008 $

[isEqualArr, reportStr] = eq(ellFirstArr, ellSecArr);
isNeqArr = ~isEqualArr;