function isPositiveMat = gt(firsrEllMat, secondEllMat)
%
% GT - checks if the first ellipsoid is bigger than the second one.
%
% Input:
%   regular:
%       firsrEllMat: ellipsoid [mRows, nCols] - array of ellipsoids.
%       secondEllMat: ellipsoid [mRows, nCols] - array of ellipsoids
%           of the corresponding dimensions.
%
% Output:
%   isPositiveMat: logical[mRows, nCols],
%       resMat(iRows, jCols) = true - if firsrEllMat(iRows, jCols)
%       contains secondEllMat(iRows, jCols)
%       when both have same center, false - otherwise.
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $
import modgen.common.throwerror;

if ~(isa(firsrEllMat, 'ellipsoid')) || ...
        ~(isa(secondEllMat, 'ellipsoid'))
    throwerror('wrongInput', ...
        '<>: both input arguments must be ellipsoids.');
end

[mRowsFstEllMatrix, nColsFstEllMatrix] = size(firsrEllMat);
nFstEllipsoids = mRowsFstEllMatrix * nColsFstEllMatrix;
[mRowsSecEllMatrix, nColsSecEllMatrix] = size(secondEllMat);
nSecEllipsoids = mRowsSecEllMatrix * nColsSecEllMatrix;

if ((mRowsFstEllMatrix ~= mRowsSecEllMatrix) || (nColsFstEllMatrix ~= ...
        nColsSecEllMatrix)) && (nFstEllipsoids > 1) && ...
        (nSecEllipsoids > 1)
    throwerror('wrongSizes', ...
        '<>: sizes of ellipsoidal arrays do not match.');
end

isPositiveMat = logical([]);
if (nFstEllipsoids > 1) && (nSecEllipsoids > 1)
    for iRow = 1:mRowsSecEllMatrix
        isPositivePartVec = logical([]);
        for jCol = 1:nColsSecEllMatrix
            isPositivePartVec = logical([isPositivePartVec ...
                isbigger(firsrEllMat(iRow, jCol), ...
                secondEllMat(iRow, jCol))]);
        end
        isPositiveMat = logical([isPositiveMat; isPositivePartVec]);
    end
elseif (nFstEllipsoids > 1)
    for iRow = 1:mRowsFstEllMatrix
        isPositivePartVec = logical([]);
        for jCol = 1:nColsFstEllMatrix
            isPositivePartVec = logical([isPositivePartVec ...
                isbigger(firsrEllMat(iRow, jCol), secondEllMat)]);
        end
        isPositiveMat = logical([isPositiveMat; isPositivePartVec]);
    end
else
    for iRow = 1:mRowsSecEllMatrix
        isPositivePartVec = logical([]);
        for jCol = 1:nColsSecEllMatrix
            isPositivePartVec = logical([isPositivePartVec ...
                isbigger(firsrEllMat, secondEllMat(iRow, jCol))]);
        end
        isPositiveMat = logical([isPositiveMat; isPositivePartVec]);
    end
end
