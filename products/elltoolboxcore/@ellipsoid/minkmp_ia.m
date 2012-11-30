function intApprEllVec = minkmp_ia(fstEll, secEll, inpEllMat, dirMat)
%
% MINKMP_IA - computation of internal approximating ellipsoids
%             of (E - Em) + (E1 + ... + En) along given directions.
%             where E = fstEll, Em = secEll,
%             E1, E2, ..., En - are ellipsoids in sumEllMat
%
%   intApprEllVec = MINKMP_IA(fstEll, secEll, inpEllMat, dirMat) -
%       Computes internal approximating
%       ellipsoids of (E - Em) + (E1 + E2 + ... + En),
%       where E1, E2, ..., En are ellipsoids in array inpEllMat,
%       E = fstEll, Em = secEll,
%       along directions specified by columns of matrix dirMat.
%
% Input:
%   regular:
%       fstEll: ellipsoid [1, 1] - first ellipsoid. Suppose
%           nDim - space dimension.
%       secEll: ellipsoid [1, 1] - second ellipsoid
%           of the same dimention.
%       inpEllMat: ellipsoid [1, nCols] - array of ellipsoids
%           of the same dimentions.
%       dirMat: double[nDim, nCols] - matrix whose columns specify the
%           directions for which the approximations should be computed.
%
% Output:
%   intApprEllVec: ellipsoid [1, nCols] - array of internal
%       approximating ellipsoids (empty, if for all specified
%       directions approximations cannot be computed).
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $

import elltool.conf.Properties;
import modgen.common.throwerror;

if ~(isa(inpEllMat, 'ellipsoid')) || ~(isa(secEll, 'ellipsoid')) ...
        || ~(isa(fstEll, 'ellipsoid'))
    fstStr = 'MINKMP_IA: first, second and third arguments ';
    secStr = 'must be ellipsoids.';
    throwerror('wrongInput', [fstStr secStr]);
end

[mRowsFstEll, nColsFstEll] = size(fstEll);
[mRowsSecEll, nColsFstEll] = size(secEll);
if (mRowsFstEll ~= 1) || (nColsFstEll ~= 1) || (mRowsSecEll ~= 1) ...
        || (nColsFstEll ~= 1)
    fstStr = 'MINKMP_IA: first and second arguments must ';
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
        'MINKMP_IA: all ellipsoids must be of the same dimension.');
end
if nDimsSecEll ~= mRowsDirMatrix
    fstStr = 'MINKMP_IA: dimension of the direction vectors must ';
    secStr = 'be the same as dimension of ellipsoids.';
    throwerror('wrongSizes', [fstStr secStr]);
end

intApprEllVec = [];

if ~isbigger(fstEll, secEll)
    if Properties.getIsVerbose()
        fprintf('MINKMP_IA: the resulting set is empty.\n');
    end
    return;
end

goodDirMat = [];
nCols = size(dirMat, 2);
[mRowsEllMatrix, nColsEllMatrix] = size(inpEllMat);
inpEllVec = reshape(inpEllMat, 1, mRowsEllMatrix*nColsEllMatrix);
isVrb = Properties.getIsVerbose();
Properties.setIsVerbose(false);


for iCol = 1:nCols
    dirVec = dirMat(:, iCol);
    if ~isbaddirection(fstEll, secEll, dirVec)
        goodDirMat = [goodDirMat dirVec];
        intApprEllVec = [intApprEllVec ...
            minksum_ia([minkdiff_ia(fstEll, secEll, dirVec) ...
            inpEllVec], dirVec)];
    end
end

Properties.setIsVerbose(isVrb);
if isempty(intApprEllVec)
    if Properties.getIsVerbose()
        fprintf('MINKMP_IA: cannot compute external approximation ');
        fprintf('for any\n           of the specified directions.\n');
    end
end
