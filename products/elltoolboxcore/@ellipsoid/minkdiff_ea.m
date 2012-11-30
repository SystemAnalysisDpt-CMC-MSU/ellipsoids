function extApprEllVec = minkdiff_ea(fstEll, secEll, directionsMat)
%
% MINKDIFF_EA - computation of external approximating ellipsoids
%               of the geometric difference of two ellipsoids along
%               given directions.
%
%   extApprEllVec = MINKDIFF_EA(fstEll, secEll, directionsMat) -
%       Computes external approximating ellipsoids of the
%       geometric difference of two ellipsoids fstEll - secEll
%       along directions specified by columns of matrix directionsMat
%
%   First condition for the approximations to be computed, is that
%   ellipsoid fstEll = E1 must be bigger than ellipsoid secEll = E2
%   in the sense that if they had the same center, E2 would be contained
%   inside E1. Otherwise, the geometric difference E1 - E2
%   is an empty set.
%   Second condition for the approximation in the given direction l
%   to exist, is the following. Given
%       P = sqrt(<l, Q1 l>)/sqrt(<l, Q2 l>)
%   where Q1 is the shape matrix of ellipsoid E1, and
%   Q2 - shape matrix of E2, and R being minimal root of the equation
%       det(Q1 - R Q2) = 0,
%   parameter P should be less than R.
%   If both of these conditions are satisfied, then external
%   approximating ellipsoid is defined by its shape matrix
%       Q = (Q1^(1/2) + S Q2^(1/2))' (Q1^(1/2) + S Q2^(1/2)),
%   where S is orthogonal matrix such that vectors
%       Q1^(1/2)l and SQ2^(1/2)l
%   are parallel, and its center
%       q = q1 - q2,
%   where q1 is center of ellipsoid E1 and q2 - center of E2.
%
% Input:
%   regular:
%       fstEll: ellipsoid [1, 1] - first ellipsoid. Suppose
%           nDim - space dimension.
%       secEll: ellipsoid [1, 1] - second ellipsoid
%           of the same dimention.
%       directionsMat: double[nDim, nCols] - matrix whose columns
%           specify the directions for which the approximations
%           should be computed.
%
% Output:
%   extApprEllVec: ellipsoid [1, nCols] - array of external
%       approximating ellipsoids (empty, if for all specified
%       directions approximations cannot be computed).
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $

import modgen.common.throwerror;
import elltool.conf.Properties;

if ~(isa(fstEll, 'ellipsoid')) || ~(isa(secEll, 'ellipsoid'))
    fstStr = 'MINKDIFF_EA: first and second arguments must ';
    secStr = 'be single ellipsoids.';
    throwerror('wrongInput', [fstStr secStr]);
end

[mRowsFstEll, nColsFstEll] = size(fstEll);
[mRowsSecEll, nColsSecEll] = size(secEll);
if (mRowsFstEll ~= 1) || (nColsFstEll ~= 1) || ...
        (mRowsSecEll ~= 1) || (nColsSecEll ~= 1)
    fstStr = 'MINKDIFF_EA: first and second arguments must ';
    secStr = 'be single ellipsoids.';
    throwerror('wrongInput', [fstStr secStr]);
end

extApprEllVec = [];

if ~isbigger(fstEll, secEll)
    if Properties.getIsVerbose()
        fstStr = 'MINKDIFF_EA: geometric difference of these two ';
        secStr = 'ellipsoids is empty set.\n'
        fprintf([fstStr secStr]);
    end
    return;
end

nRowsDirMat = size(directionsMat, 1);
nDims = dimension(fstEll);
if nRowsDirMat ~= nDims
    fstStr = 'MINKDIFF_EA: dimension of the direction vectors must ';
    secStr = 'be the same as dimension of ellipsoids.';
    throwerror('wrongSizes', [fstStr secStr]);
end
centVec = fstEll.center - secEll.center;
fstEllShMat = fstEll.shape;
secEllShMat = secEll.shape;
directionsMat  = ellipsoid.rm_bad_directions(fstEllShMat, ...
    secEllShMat, directionsMat);
nColsDirMat  = size(directionsMat, 2);
if nColsDirMat < 1
    if Properties.getIsVerbose()
        fprintf('MINKDIFF_EA: cannot compute external approximation ');
        fprintf('for any\n             of the specified directions.\n');
    end
    return;
end
if rank(fstEllShMat) < size(fstEllShMat, 1)
    fstEllShMat = ellipsoid.regularize(fstEllShMat,fstEll.absTol);
end
if rank(secEllShMat) < size(secEllShMat, 1)
    secEllShMat = ellipsoid.regularize(secEllShMat,secEll.absTol);
end

fstEllShMat = sqrtm(fstEllShMat);
secEllShMat = sqrtm(secEllShMat);

for iCol = 1:nColsDirMat
    dirVec  = directionsMat(:, iCol);
    rotMat = ell_valign(fstEllShMat*dirVec, secEllShMat*dirVec);
    shMat = fstEllShMat - rotMat*secEllShMat;
    extApprEllVec = [extApprEllVec ellipsoid(centVec, shMat'*shMat)];
end
