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
%
% $Author: Guliev Rustam <glvrst@gmail.com> $   $Date: Dec-2012$
% $Copyright: Moscow State University,
%             Faculty of Computational Mathematics and Cybernetics,
%             Science, System Analysis Department 2012 $
%

import modgen.common.throwerror;
import modgen.common.checkmultvar;
import elltool.conf.Properties;
import elltool.logging.Log4jConfigurator;

persistent logger;

ellipsoid.checkIsMe(fstEll,'first');
ellipsoid.checkIsMe(secEll,'second');
checkmultvar('isscalar(x1)&&isscalar(x2)',2,fstEll,secEll,...
    'errorTag','wrongInput','errorMessage',...
    'first and second arguments must be single ellipsoids.');

extApprEllVec = [];

if ~isbigger(fstEll, secEll)
    if Properties.getIsVerbose()
        if isempty(logger)
            logger=Log4jConfigurator.getLogger();
        end
        fstStr = 'MINKDIFF_EA: geometric difference of these two ';
        secStr = 'ellipsoids is empty set.';
        logger.info([fstStr secStr]);
    end
    return;
end

checkmultvar('(x1==x2)',2,dimension(fstEll),size(directionsMat, 1),...
    'errorTag','wrongSizes','errorMessage',...
    'direction vectors ans ellipsoids dimensions mismatch.');

centVec = fstEll.center - secEll.center;
fstEllShMat = fstEll.shape;
secEllShMat = secEll.shape;
directionsMat  = ellipsoid.rm_bad_directions(fstEllShMat, ...
    secEllShMat, directionsMat);
nDirs  = size(directionsMat, 2);
if nDirs < 1
    if Properties.getIsVerbose()
        if isempty(logger)
            logger=Log4jConfigurator.getLogger();
        end
        logger.info('MINKDIFF_EA: cannot compute external approximation ');
        logger.info('for any of the specified directions.');
    end
    return;
end
if isdegenerate(fstEll)
    fstEllShMat = ellipsoid.regularize(fstEllShMat,fstEll.absTol);
end
if isdegenerate(secEll)
    secEllShMat = ellipsoid.regularize(secEllShMat,secEll.absTol);
end

fstEllSqrtShMat = sqrtm(fstEllShMat);
secEllSqrtShMat = sqrtm(secEllShMat);

srcMat=fstEllSqrtShMat*directionsMat;
dstMat=secEllSqrtShMat*directionsMat;
rotArray=gras.la.mlorthtransl(dstMat, srcMat);

extApprEllVec = repmat(ellipsoid,1,nDirs);
arrayfun(@(x) fSingleDir(x), 1:nDirs)
    function fSingleDir(index)
        rotMat = rotArray(:,:,index);
        shMat = fstEllSqrtShMat - rotMat*secEllSqrtShMat;
        extApprEllVec(index).center = centVec;
        extApprEllVec(index).shape = shMat'*shMat;
    end
end