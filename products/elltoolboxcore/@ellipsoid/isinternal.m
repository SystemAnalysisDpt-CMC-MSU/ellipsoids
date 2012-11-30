function isPositiveVec = isinternal(myEllMat, matrixOfVecMat, mode)
%
% ISINTERNAL - checks if given points belong to the union or intersection
%              of ellipsoids in the given array.
%
%   isPositiveVec = ISINTERNAL(myEllMat,  matrixOfVecMat, mode) - Checks
%       if vectors specified as columns of matrix matrixOfVecMat
%       belong to the union (mode = 'u'), or intersection (mode = 'i')
%       of the ellipsoids in myEllMat. If myEllMat is a single
%       ellipsoid, then this function checks if points in matrixOfVecMat
%       belong to myEllMat or not. Ellipsoids in E must be
%       of the same dimension. Column size of matrix  matrixOfVecMat
%       should match the dimension of ellipsoids.
%
%    Let myEllMat(iEll) = E(q, Q) be an ellipsoid with center q and shape
%    matrix Q. Checking if given vector matrixOfVecMat = x belongs
%    to E(q, Q) is equivalent to checking if inequality
%                    <(x - q), Q^(-1)(x - q)> <= 1
%    holds.
%    If x belongs to at least one of the ellipsoids in the array, then it
%    belongs to the union of these ellipsoids. If x belongs to all
%    ellipsoids in the array,
%    then it belongs to the intersection of these ellipsoids.
%    The default value of the specifier s = 'u'.
%
%    WARNING: be careful with degenerate ellipsoids.
%
% Input:
%   regular:
%       myEllMat: ellipsoid [mRowsOfEllMat, nColsOfEllMat] - matrix
%           of ellipsoids.
%       matrixOfVecMat: double [mRows, nColsOfVec] - matrix which
%           specifiy points.
%
%   optional:
%       mode: char[1, 1] - 'u' or 'i', go to description.
%
% Output:
%    isPositiveVec: logical[1, nColsOfVec] -
%       true - if vector belongs to the union or intersection
%       of ellipsoids, false - otherwise.
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $

import elltool.conf.Properties;
import modgen.common.throwerror;

if ~isa(myEllMat, 'ellipsoid')
    fstErrMsg = 'ISINTERNAL: first argument must be an ellipsoid, ';
    secErrMsg = 'or an array of ellipsoids.';
    throwerror('wrongInput', [fstErrMsg secErrMsg]);
end

nDimsMat = dimension(myEllMat);
maxDim    = min(min(nDimsMat));
minDim    = max(max(nDimsMat));
if maxDim ~= minDim
    throwerror('wrongSizes', ...
        'ISINTERNAL: ellipsoids must be of the same dimension.');
end

if ~(isa(matrixOfVecMat, 'double'))
    throwerror('wrongInput', ...
        'ISINTERNAL: second argument must be an array of vectors.');
end

if (nargin < 3) || ~(ischar(mode))
    mode = 'u';
end

if (mode ~= 'u') && (mode ~= 'i')
    fstErrMsg = 'ISINTERNAL: third argument is expected ';
    secErrMsg = 'to be either ''u'', or ''i''.';
    throwerror('wrongInput', [fstErrMsg secErrMsg]);
end

[mRows, nCols] = size(matrixOfVecMat);
if mRows ~= minDim
    throwerror('wrongInput', ...
        'ISINTERNAL: dimensions of ellipsoid and vector do not match.');
end

isPositiveVec = logical(zeros(1,nCols));
for iCol = 1:nCols
    isPositiveVec(iCol) = isinternal_sub(myEllMat,...
        matrixOfVecMat(:, iCol), mode, mRows);
end

end



%%%%%%%%

function isPositive = isinternal_sub(myEllMat, xVec, mode, mRows)
%
% ISINTERNAL_SUB - compute result for single vector.
%
% Input:
%   regular:
%       myEllMat: ellipsod [mRowsOfEllMat, nColsOfEllMat] - matrix of
%           ellipsoids.
%       xVec: double [mRows, 1] - matrix which specifiy points.
%       mRows: double[1, 1] - dimension of ellipsoids
%           in myEllMat and xVec.
%
%   properties:
%       mode: char[1, 1] - 'u' or 'i', go to description.
%
% Output:
%    isPositive: logical[1, nColsOfVec] -
%       true - if vector belongs to the union or intersection
%       of ellipsoids, false - otherwise.
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $

import elltool.conf.Properties;

if mode == 'u'
    isPositive = false;
else
    isPositive = true;
end

absTolMat = getAbsTol(myEllMat);
[mEllRows, nEllCols] = size(myEllMat);
for iEllRow = 1:mEllRows
    for jEllCol = 1:nEllCols
        myEllCentVec = xVec - myEllMat(iEllRow, jEllCol).center;
        myEllShMat = myEllMat(iEllRow, jEllCol).shape;
        
        if rank(myEllShMat) < mRows
            if Properties.getIsVerbose()
                fstFprintStr = ...
                    'ISINTERNAL: Warning! There is degenerate ';
                secFprintStr = 'ellipsoid in the array.\n';
                fprintf([fstFprintStr secFprintStr]);
                fprintf('            Regularizing...\n');
            end
            myEllShMat = ellipsoid.regularize(myEllShMat,...
                absTolMat(iEllRow,jEllCol));
        end
        
        rScal = myEllCentVec' * ell_inv(myEllShMat) * myEllCentVec;
        if (mode == 'u')
            if (rScal < 1) || (abs(rScal - 1) ...
                    < absTolMat(iEllRow,jEllCol))
                isPositive = true;
                return;
            end
        else
            if (rScal > 1) && (abs(rScal - 1) ...
                    > absTolMat(iEllRow,jEllCol))
                isPositive = false;
                return;
            end
        end
    end
end

end
