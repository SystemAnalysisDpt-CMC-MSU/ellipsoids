function [isPosArr reportStr] = ne(fstHypArr, secHypArr)
%
% NE - The opposite of EQ.
%
% Input:
%   regular:
%       fstHypArr: hyperplane [nDims1, nDims2, ...]/hyperplane [1, 1] -
%           first array of hyperplanes.
%       secHypArr: hyperplane [nDims1, nDims2, ...]/hyperplane [1, 1] -
%           second array of hyperplanes.
%
% Output:
%   isPosArr: logical[nDims1, nDims2, ...] - false -
%       if fstHypArr(iDim1, iDim2, ...) == secHypArr(iDim1, iDim2, ...),
%       true - otherwise. If size of fstHypArr is [1, 1], then checks
%       if fstHypArr == secHypArr(iDim1, iDim2, ...)
%       for all iDim1, iDim2, ... , and vice versa.
%   reportStr: char[1,] - comparison report
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $
%
% $Authors:
%   Peter Gagarinov  <pgagarinov@gmail.com> $ $Date: Dec-2012$
%   Aushkap Nikolay <n.aushkap@gmail.com> $ $Date: Dec-2012$
% $Copyright: Moscow State University,
%   Faculty of Computational Mathematics and Computer Science,
%   System Analysis Department 2012 $

[isPosArr reportStr] = eq(fstHypArr, secHypArr);
isPosArr = ~isPosArr;
