function extApprEllVec = minkmp_ea(fstEll, secEll, inpEllMat, dirMat)
%
% MINKMP_EA - computation of external approximating ellipsoids
%             of (E0 - E) + (E1 + ... + En) in given directions.
%
%   EA = MINKMP_EA(E0, E, EE, L) - Computes external approximating
%       ellipsoids of (E0 - E) + (E1 + E2 + ... + En),
%       where E1, E2, ..., En are ellipsoids in array EE,
%       in directions specified by columns of matrix L.
%
% Input:
%   regular:
%       fstEll: ellipsoid [1, 1] - first ellipsoid. Suppose
%           nDims - space dimension.
%       secEll: ellipsoid [1, 1] - second ellipsoid
%           of the same dimention.
%       inpEllMat: ellipsoid [mRows, nCols] - matrix of ellipsoids
%           of the same dimentions.
%       dirMat: double[nDims, nCols] - matrix whose columns specify the
%           directions for which the approximations should be computed.
%
% Output:
%   extApprEllVec: ellipsoid [1, nCols] - array of external
%       approximating ellipsoids (empty, if for all specified
%       directions approximations cannot be computed).
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $

import elltool.conf.Properties;
import modgen.common.throwerror;

if ~(isa(inpEllMat, 'ellipsoid')) || ~(isa(secEll, 'ellipsoid')) ...
        || ~(isa(fstEll, 'ellipsoid'))
    fstStr = 'MINKMP_EA: first, second and third arguments ';
    secStr = 'must be ellipsoids.';
    throwerror('wrongInput', [fstStr secStr]);
end

[mRowsFstEll, nColsFstEll] = size(fstEll);
[mRowsSecEll, nColsSecEll] = size(secEll);
if (mRowsFstEll ~= 1) || (nColsFstEll ~= 1) || ...
        (mRowsSecEll ~= 1) || (nColsSecEll ~= 1)
    fstStr = 'MINKMP_EA: first and second arguments must ';
    secStr = 'be single ellipsoids.';
    throwerror('wrongInput', [fstStr secStr]);
end

mRowsDirMatrix  = size(dirMat, 1);
nDimsFstEll  = dimension(fstEll);
nDimsSecEll  = dimension(secEll);
minDimEll = min(min(dimension(inpEllMat)));
maxDimEll = max(max(dimension(inpEllMat)));
if (minDimEll ~= maxDimEll) || (minDimEll ~= nDimsSecEll) ...
        || (nDimsFstEll ~= nDimsSecEll)
    throwerror('wrongSizes', ...
        'MINKMP_EA: all ellipsoids must be of the same dimension.');
end
if nDimsSecEll ~= mRowsDirMatrix
    fstStr = 'MINKMP_EA: dimension of the direction vectors must ';
    secStr = 'be the same as dimension of ellipsoids.';
    throwerror('wrongSizes', [fstStr secStr]);
end

extApprEllVec = [];

if ~isbigger(fstEll, secEll)
    if Properties.getIsVerbose()
        fprintf('MINKMP_EA: the resulting set is empty.\n');
    end
    return;
end

goodDirMat = [];
nCols = size(dirMat, 2);
[mRowsEllMatrix, nColsEllMatrix]  = size(inpEllMat);
inpEllVec = reshape(inpEllMat, 1, mRowsEllMatrix*nColsEllMatrix);
isVrb = Properties.getIsVerbose();
Properties.setIsVerbose(false);

for iCol = 1:nCols
    dirVec = dirMat(:, iCol);
    if ~isbaddirection(fstEll, secEll, dirVec)
        goodDirMat = [goodDirMat dirVec];
        extApprEllVec = [extApprEllVec minksum_ea([minkdiff_ea(fstEll, ...
            secEll, dirVec) inpEllVec], dirVec)];
    end
end

Properties.setIsVerbose(isVrb);

if isempty(extApprEllVec)
    if Properties.getIsVerbose()
        fprintf('MINKMP_EA: cannot compute external approximation ');
        fprintf('for any\n           of the specified directions.\n');
    end
end
