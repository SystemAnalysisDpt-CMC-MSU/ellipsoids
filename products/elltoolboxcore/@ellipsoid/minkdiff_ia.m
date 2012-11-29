function intApprEllVec = minkdiff_ia(fstEll, secEll, directionsMat)
%
% MINKDIFF_IA - computation of internal approximating ellipsoids
%               of the geometric difference of two ellipsoids in
%               given directions.
%
%   IA = MINKDIFF_IA(E1, E2, L) - Computes internal approximating
%       ellipsoids of the geometric difference of two ellipsoids E1 - E2
%       in directions specified by columns of matrix L.
%
%   First condition for the approximations to be computed, is that
%   ellipsoid E1 must be bigger than ellipsoid E2 in the sense that
%   if they had the same center, E2 would be contained inside E1.
%   Otherwise, the geometric difference E1 - E2 is an empty set.
%   Second condition for the approximation in the given direction l
%   to exist, is the following. Given
%                  P = sqrt(<l, Q1 l>)/sqrt(<l, Q2 l>)
%   where Q1 is the shape matrix of ellipsoid E1, and Q2 - shape
%   matrix of E2, and R being minimal root of the equation
%                  det(Q1 - R Q2) = 0,
%   parameter P should be less than R.
%   If these two conditions are satisfied, then internal approximating
%   ellipsoid for the geometric difference E1 - E2 in the direction l
%   is defined by its shape matrix
%                Q = (1 - (1/P)) Q1 + (1 - P) Q2
%   and its center
%                q = q1 - q2,
%   where q1 is center of E1 and q2 - center of E2.
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
%   intApprEllVec: ellipsoid [1, nCols] - array of internal
%       approximating ellipsoids (empty, if for all specified directions
%       approximations cannot be computed).
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $

import modgen.common.throwerror;
import elltool.conf.Properties;

if ~(isa(fstEll, 'ellipsoid')) || ~(isa(secEll, 'ellipsoid'))
    fstStr = 'MINKDIFF_IA: first and second arguments must ';
    secStr = 'be single ellipsoids.';
    throwerror('wrongInput', [fstStr secStr]);
end

[mRowsFstEll, nColsFstEll] = size(fstEll);
[mRowsSecEll, nColsSecEll] = size(secEll);
if (mRowsFstEll ~= 1) || (nColsFstEll ~= 1) || ...
        (mRowsSecEll ~= 1) || (nColsSecEll ~= 1)
    fstStr = 'MINKDIFF_IA: first and second arguments must ';
    secStr = 'be single ellipsoids.';
    throwerror('wrongInput', [fstStr secStr]);
end

intApprEllVec = [];

if isbigger(fstEll, secEll) == 0
    if Properties.getIsVerbose()
        fstStr = 'MINKDIFF_IA: geometric difference of these two ';
        secStr = 'ellipsoids is empty set.\n';
        fprintf([fstStr secStr]);
    end
    return;
end

nRowsDirMat = size(directionsMat, 1);
nDims = dimension(fstEll);
if nRowsDirMat ~= nDims
    fstStr = 'MINKDIFF_IA: dimension of the direction vectors must ';
    secStr = 'be the same as dimension of ellipsoids.';
    throwerror('wrongSizes', [fstStr secStr]);
end
centVec = fstEll.center - secEll.center;
fstEllShMat = fstEll.shape;
if rank(fstEllShMat) < size(fstEllShMat, 1)
    fstEllShMat = ellipsoid.regularize(fstEllShMat,fstEll.absTol);
end
secEllShMat = secEll.shape;
if rank(secEllShMat) < size(secEllShMat, 1)
    secEllShMat = ellipsoid.regularize(secEllShMat,secEll.absTol);
end
directionsMat  = ellipsoid.rm_bad_directions(fstEllShMat, ...
    secEllShMat, directionsMat);
nColsDirMat  = size(directionsMat, 2);
if nColsDirMat < 1
    if Properties.getIsVerbose()
        fprintf('MINKDIFF_IA: cannot compute internal approximation');
        fprintf(' for any\n             of the specified directions.\n');
    end
    return;
end
for iCol = 1:nColsDirMat
    nColsFstEll  = directionsMat(:, iCol);
    coef = (sqrt(nColsFstEll'*fstEllShMat*nColsFstEll))/...
        (sqrt(nColsFstEll'*secEllShMat*nColsFstEll));
    shMat = (1 - (1/coef))*fstEllShMat + (1 - coef)*secEllShMat;
    intApprEllVec = [intApprEllVec ellipsoid(centVec, shMat)];
end
