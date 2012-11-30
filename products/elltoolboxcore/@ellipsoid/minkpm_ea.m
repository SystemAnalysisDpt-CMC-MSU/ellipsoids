function ExtApprEllVec = minkpm_ea(inpEllMat, inpEll, dirMat)
%
% MINKPM_EA - computation of external approximating ellipsoids
%             of (E1 + E2 + ... + En) - E along given directions.
%             where E = inpEll,
%             E1, E2, ... En - are ellipsoids in inpEllMat.
%
%   ExtApprEllVec = MINKPM_EA(inpEllMat, inpEll, dirMat) - Computes
%       external approximating ellipsoids of
%       (E1 + E2 + ... + En) - E, where E1, E2, ..., En are ellipsoids
%       in array inpEllMat, E = inpEll,
%       along directions specified by columns of matrix dirMat.
%
% Input:
%   regular:
%       inpEllMat: ellipsoid [mRowsInpEllMat, nColsInpEllMat] -
%           matrix of ellipsoids of the same dimentions.
%       inpEll: ellipsoid [1, 1] - ellipsoid of the same dimention.
%       dirMat: double[nDim, nCols] - matrix whose columns specify
%           the directions for which the approximations
%           should be computed.
%
% Output:
%   extApprEllVec: ellipsoid [1, nCols]/[0, 0] - array of external
%       approximating ellipsoids. Empty, if for all specified
%       directions approximations cannot be computed.
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $

import modgen.common.throwerror;
import elltool.conf.Properties;

if ~(isa(inpEllMat, 'ellipsoid')) || ~(isa(inpEll, 'ellipsoid'))
    throwerror('wrongInput', ...
        'MINKPM_EA: first and second arguments must be ellipsoids.');
end

[mRowsInpEll, nColsInpEll] = size(inpEll);
if (mRowsInpEll ~= 1) || (nColsInpEll ~= 1)
    throwerror('wrongInput', ...
        'MINKPM_EA: second argument must be single ellipsoid.');
end

mRowsDirMatrix  = size(dirMat, 1);
nDims = dimension(inpEll);
minDimInpEll = min(min(dimension(inpEllMat)));
maxDimInpEll = max(max(dimension(inpEllMat)));
if (minDimInpEll ~= maxDimInpEll) || (minDimInpEll ~= nDims)
    throwerror('wrongSizes', ...
        'MINKPM_EA: all ellipsoids must be of the same dimension.');
end
if nDims ~= mRowsDirMatrix
    fstStr = 'MINKPM_EA: dimension of the direction vectors must ';
    secStr = 'be the same as dimension of ellipsoids.';
    throwerror('wrongSizes', [fstStr secStr]);
end

nCols = size(dirMat, 2);
ExtApprEllVec = [];
isVrb = Properties.getIsVerbose();
Properties.setIsVerbose(false);

% sanity check: the approximated set should be nonempty
for iCol = 1:nCols
    [svdUMat, ~, ~] = svd(dirMat(:, iCol));
    fstExtApprEllVec = minksum_ea(inpEllMat, svdUMat);
    if min(fstExtApprEllVec > inpEll) < 1
        if isVrb > 0
            fprintf('MINKPM_EA: the resulting set is empty.\n');
        end
        Properties.setIsVerbose(isVrb);
        return;
    end
end

secExtApprEllVec = minksum_ea(inpEllMat, dirMat);

for iCol = 1:nCols
    extApprEll = secExtApprEllVec(iCol);
    dirVec = dirMat(:, iCol);
    if ~isbaddirection(extApprEll, inpEll, dirVec)
        ExtApprEllVec = [ExtApprEllVec ...
            minkdiff_ea(extApprEll, inpEll, dirVec)];
    end
end

Properties.setIsVerbose(isVrb);

if isempty(ExtApprEllVec)
    if Properties.getIsVerbose()
        fprintf('MINKPM_EA: cannot compute external ');
        fprintf('approximation for any\n           ');
        fprintf('of the specified directions.\n');
    end
end
