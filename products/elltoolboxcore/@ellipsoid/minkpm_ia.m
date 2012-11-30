function intApprEllVec = minkpm_ia(inpEllMat, inpEll, dirMat)
%
% MINKPM_IA - computation of internal approximating ellipsoids
%             of (E1 + E2 + ... + En) - E along given directions.
%             where E = inpEll,
%             E1, E2, ... En - are ellipsoids in inpEllMat.
%
%   intApprEllVec = MINKPM_IA(inpEllMat, inpEll, dirMat) - Computes
%       internal approximating ellipsoids of
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
%   intApprEllVec: ellipsoid [1, nCols]/[0, 0] - array of internal
%       approximating ellipsoids. Empty, if for all specified
%       directions approximations cannot be computed.
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $

import modgen.common.throwerror;
import elltool.conf.Properties;


if ~(isa(inpEllMat, 'ellipsoid')) || ~(isa(inpEll, 'ellipsoid'))
    throwerror('wrongInput', ...
        'MINKPM_IA: first and second arguments must be ellipsoids.');
end

[mRowsInpEll, nColsInpEll] = size(inpEll);
if (mRowsInpEll ~= 1) || (nColsInpEll ~= 1)
    throwerror('wrongInput', ...
        'MINKPM_IA: second argument must be single ellipsoid.');
end

mRowsDirMatrix = size(dirMat, 1);
nDims = dimension(inpEll);
minDimInpEll = min(min(dimension(inpEllMat)));
maxDimInpEll = max(max(dimension(inpEllMat)));
if (minDimInpEll ~= maxDimInpEll) || (minDimInpEll ~= nDims)
    throwerror('wrongSizes', ...
        'MINKPM_IA: all ellipsoids must be of the same dimension.');
end
if nDims ~= mRowsDirMatrix
    fstStr = 'MINKPM_IA: dimension of the direction vectors must ';
    secStr = 'be the same as dimension of ellipsoids.';
    throwerror('wrongSizes', [fstStr secStr]);
end

nCols = size(dirMat, 2);
intApprEllVec = [];
fstIntApprEllMat = minksum_ia(inpEllMat, dirMat);
isVrb = Properties.getIsVerbose();
Properties.setIsVerbose(false);

for i = 1:nCols
    fstIntApprEll = fstIntApprEllMat(i);
    dirVec = dirMat(:, i);
    if isbigger(fstIntApprEll, inpEll)
        if ~isbaddirection(fstIntApprEll, inpEll, dirVec)
            intApprEllVec = [intApprEllVec ...
                minkdiff_ia(fstIntApprEll, inpEll, dirVec)];
        end
    end
end

Properties.setIsVerbose(isVrb);

if isempty(intApprEllVec)
    if Properties.getIsVerbose()
        fprintf('MINKPM_IA: cannot compute internal ');
        fprintf('approximation for any\n           ');
        fprintf('of the specified directions.\n')
    end
end
