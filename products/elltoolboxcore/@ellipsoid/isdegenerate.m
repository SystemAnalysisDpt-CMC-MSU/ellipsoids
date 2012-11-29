function isPositiveMat = isdegenerate(myEllMat)
%
% ISDEGENERATE - checks if the ellipsoid is degenerate.
%
% Input:
%   regular:
%       myEllMat: ellipsod [mRows, nCols] - single ellipsoid.
%
% Output:
%   isResMat: logical[mRows, nCols], isPositiveMat(iRow, jCol) = true 
%       if ellipsoid myEllMat(iRow, jCol) is degenerate,
%       false - otherwise.
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $

import modgen.common.throwerror;
[mRows, nCols] = size(myEllMat);
isPositiveMat = false(mRows, nCols);
for iRow = 1:mRows
    for jCol = 1:nCols
        if isempty(myEllMat(iRow,jCol))
            throwerror('wrongInput:emptyEllipsoid', ...
                'ISDEGENERATE: input argument is empty.');
        end
        if rank(myEllMat(iRow, jCol).shape) ...
                < size(myEllMat(iRow, jCol).shape, 1)
            isPositiveMat(iRow, jCol) = true;
        end
    end
end
