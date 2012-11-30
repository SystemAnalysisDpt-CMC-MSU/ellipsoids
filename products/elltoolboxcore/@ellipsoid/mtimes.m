function outEllVec = mtimes(multMat, inpEllVec)
%
% MTIMES - overloaded operator '*'.
%
%   Multiplication of the ellipsoid by a matrix or a scalar.
%   If inpEllVec(iEll) = E(q, Q) is an ellipsoid, and
%   multMat = A - matrix of suitable dimensions,
%   then A E(q, Q) = E(Aq, AQA').
%
% Input:
%   regular:
%       multMat: double[mRows, nDims]/[1, 1] - scalar or
%           matrix in R^{mRows x nDim}
%       inpEllVec: ellipsoid [1, nCols] - array of ellipsoids.
%
% Output:
%   outEllVec: ellipsoid [1, nCols] - resulting ellipsoids.
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $

import modgen.common.throwerror;
if ~(isa(multMat, 'double')) || ~(isa(inpEllVec, 'ellipsoid'))
    fstStr = 'MTIMES: first multiplier is expected';
    secStr = ' to be a matrix or a scalar,\n        ';
    thdStr = 'and second multiplier - an ellipsoid.';
    throwerror('wrongInput', [fstStr secStr thdStr]);
end

[mRows, nDims] = size(multMat);
nDimsInpEll = dimension(inpEllVec);
maxDims = max(max(nDimsInpEll));
minDims = min(min(nDimsInpEll));
if ((maxDims ~= minDims) && (nDims ~= 1) && (mRows ~= 1)) ...
        || ((maxDims ~= nDims) && (nDims ~= 1) && (mRows ~= 1))
    throwerror('wrongSizes', 'MTIMES: dimensions do not match.');
end

[mRowsInpEll, nCols] = size(inpEllVec);
for iRow = 1:mRowsInpEll
    for jCol = 1:nCols
        shMat = multMat*(inpEllVec(iRow, jCol).shape)*multMat';
        shMat = 0.5*(shMat + shMat');
        subOutEll(jCol) = ellipsoid(multMat *...
            (inpEllVec(iRow, jCol).center), shMat);
    end
    if iRow == 1
        outEllVec = subOutEll;
    else
        outEllVec = [outEllVec; subOutEll];
    end
    clear subOutEll;
end
