function intApprEllVec = minkdiff_ia(fstEll, secEll, directionsMat)
%
% MINKDIFF_IA - computation of internal approximating ellipsoids
%               of the geometric difference of two ellipsoids along
%               given directions.
%
%   intApprEllVec = MINKDIFF_IA(fstEll, secEll, directionsMat) -
%       Computes internal approximating ellipsoids of the geometric
%       difference of two ellipsoids fstEll - secEll along directions
%       specified by columns of matrix directionsMat.
%
%   First condition for the approximations to be computed, is that
%   ellipsoid fstEll = E1 must be bigger than ellipsoid secEll = E2
%   in the sense that if they had the same center, E2 would be contained
%   inside E1. Otherwise, the geometric difference E1 - E2 is an
%   empty set. Second condition for the approximation in the given
%   direction l to exist, is the following. Given
%       P = sqrt(<l, Q1 l>)/sqrt(<l, Q2 l>)
%   where Q1 is the shape matrix of ellipsoid E1,
%   and Q2 - shape matrix of E2, and R being minimal root of the equation
%       det(Q1 - R Q2) = 0,
%   parameter P should be less than R.
%   If these two conditions are satisfied, then internal approximating
%   ellipsoid for the geometric difference E1 - E2 along the
%   direction l is defined by its shape matrix
%       Q = (1 - (1/P)) Q1 + (1 - P) Q2
%   and its center
%       q = q1 - q2,
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
% Example:
%   firstEllObj = ellipsoid([-2; -1], [4 -1; -1 1]);
%   secEllObj = 3*ell_unitball(2);
%   dirsMat = [1 0; 1 1; 0 1; -1 1]';
%   internalEllVec = secEllObj.minkdiff_ia(firstEllObj, dirsMat)
% 
%   internalEllVec =
%   1x2 array of ellipsoids.
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 
%              2004-2008 $
%
% $Author: Guliev Rustam <glvrst@gmail.com> $   
% $Date: Dec-2012$
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
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
    'first and second arguments must be single ellipsoids.')


if ~isbigger(fstEll, secEll)
    intApprEllVec = [];
    if Properties.getIsVerbose()
        if isempty(logger)
            logger=Log4jConfigurator.getLogger();
        end
        fstStr = 'MINKDIFF_IA: geometric difference of these two ';
        secStr = 'ellipsoids is empty set.';
        logger.info([fstStr secStr]);
    end
    return;
end

checkmultvar('(x1==x2)',2,dimension(fstEll),size(directionsMat, 1),...
    'errorTag','wrongSizes','errorMessage',...
    'direction vectors ans ellipsoids dimensions mismatch.');

centVec = fstEll.centerVec - secEll.centerVec;
fstEllShMat = fstEll.shapeMat;
if isdegenerate(fstEll)
    fstEllShMat = ellipsoid.regularize(fstEllShMat,fstEll.absTol);
end
secEllShMat = secEll.shapeMat;
if isdegenerate(secEll)
    secEllShMat = ellipsoid.regularize(secEllShMat,secEll.absTol);
end
absTolVal=min(fstEll.absTol, secEll.absTol);
directionsMat  = ellipsoid.rm_bad_directions(fstEllShMat, ...
    secEllShMat, directionsMat,absTolVal);
nDirs  = size(directionsMat, 2);
if nDirs < 1
    intApprEllVec = [];
    if Properties.getIsVerbose()
        if isempty(logger)
            logger=Log4jConfigurator.getLogger();
        end
        logger.info('MINKDIFF_IA: cannot compute internal approximation');
        logger.info(' for any of the specified directions.');
    end
    return;
end

numVec=sum((fstEllShMat*directionsMat).*directionsMat,1);
denomVec=sum((secEllShMat*directionsMat).*directionsMat,1);
coefVec=numVec./denomVec;

intApprEllVec(nDirs) = ellipsoid();
arrayfun(@(x) fSingleDir(x), 1:nDirs)
    function fSingleDir(index)
        coef = realsqrt(coefVec(index));
        shMat = (1 - (1/coef))*fstEllShMat + (1 - coef)*secEllShMat;
        intApprEllVec(index).centerVec = centVec;
        intApprEllVec(index).shapeMat = shMat;
    end
end