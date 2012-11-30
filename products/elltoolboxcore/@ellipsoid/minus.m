function outEllVec = minus(inpEllVec, inpVec)
%
% MINUS - overloaded operator '-'
%
%   Operation E - b where E = inpEll is an ellipsoid in R^n,
%   and b = inpVec - vector in R^n. If E(q, Q) is an ellipsoid
%   with center q and shape matrix Q, then
%   E(q, Q) - b = E(q - b, Q).
%
% Input:
%   regular:
%       inpEllVec: ellipsoid [1, nCols] - array of ellipsoids
%           of the same dimentions nDims.
%       inpVec: double[nDims, 1] - vector.
%
% Output:
%   outEllVec: ellipsoid [1, nCols] - array of ellipsoids with
%       same shapes as inpEllVec, but with centers
%       shifted by vectors in -inpVec.
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $

import modgen.common.throwerror;

if ~(isa(inpEllVec, 'ellipsoid'))
    throwerror('wrongInput', ...
        'MINUS: first argument must be ellipsoid.');
end
if isa(inpEllVec, 'ellipsoid') && ~(isa(inpVec, 'double'))
    fstStr = 'MINUS: this operation is only permitted between ';
    secStr = 'ellipsoid and vector in R^n.';
    throwerror('wrongInput', [fstStr secStr]);
end

nDimsInpEll = dimension(inpEllVec);
maxDim = max(max(nDimsInpEll));
minDim = min(min(nDimsInpEll));
if maxDim ~= minDim
    fstStr = 'MINUS: all ellipsoids in the array must be ';
    secStr = 'of the same dimension.';
    throwerror('wrongSizes', [fstStr secStr]);
end

[mRows, nColsInpVec] = size(inpVec);
if (nColsInpVec ~= 1) || (mRows ~= minDim)
    throwerror('wrongSizes', ...
        'MINUS: vector dimension does not match.');
end

[mRows, nCOls] = size(inpEllVec);
for iRow = 1:mRows
    for jCol = 1:nCOls
        subEll(jCol) = inpEllVec(iRow, jCol);
        subEll(jCol).center = inpEllVec(iRow, jCol).center - inpVec;
    end
    if iRow == 1
        outEllVec = subEll;
    else
        outEllVec = [outEllVec; subEll];
    end
    clear subEll;
end
