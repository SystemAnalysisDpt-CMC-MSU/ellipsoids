function intApprEllVec = minkmp_ia(fstEll, secEll, sumEllArr, dirMat)
%
% MINKMP_IA - computation of internal approximating ellipsoids
%             of (E - Em) + (E1 + ... + En) along given directions.
%             where E = fstEll, Em = secEll,
%             E1, E2, ..., En - are ellipsoids in sumEllArr
%
%   intApprEllVec = MINKMP_IA(fstEll, secEll, sumEllArr, dirMat) -
%       Computes internal approximating
%       ellipsoids of (E - Em) + (E1 + E2 + ... + En),
%       where E1, E2, ..., En are ellipsoids in array sumEllArr,
%       E = fstEll, Em = secEll,
%       along directions specified by columns of matrix dirMat.
%
% Input:
%   regular:
%       fstEll: ellipsoid [1, 1] - first ellipsoid. Suppose
%           nDim - space dimension.
%       secEll: ellipsoid [1, 1] - second ellipsoid
%           of the same dimention.
%       sumEllArr: ellipsoid [nDims1, nDims2,...,nDimsN] - array of
%           ellipsoids of the same dimentions.
%       dirMat: double[nDim, nCols] - matrix whose columns specify the
%           directions for which the approximations should be computed.
%
% Output:
%   intApprEllVec: ellipsoid [1, nCols] - array of internal
%       approximating ellipsoids (empty, if for all specified
%       directions approximations cannot be computed).
%
% Example:
%   firstEllObj = ellipsoid([-2; -1], [4 -1; -1 1]);
%   secEllObj = 3*ell_unitball(2);
%   dirsMat = [1 0; 1 1; 0 1; -1 1]';
%   bufEllVec = [secEllObj firstEllObj];
%   internalEllVec = secEllObj.minkmp_ia(firstEllObj, bufEllVec, dirsMat)
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

import elltool.conf.Properties;
import modgen.common.throwerror;
import modgen.common.checkmultvar;
import elltool.logging.Log4jConfigurator;

persistent logger;

ellipsoid.checkIsMe(fstEll,'first');
ellipsoid.checkIsMe(secEll,'second');
ellipsoid.checkIsMe(sumEllArr,'third');
checkmultvar('isscalar(x1)&&isscalar(x2)',2,fstEll,secEll,...
    'errorTag','wrongInput','errorMessage',...
    'first and second arguments must be single ellipsoids.')

modgen.common.checkvar( sumEllArr , 'numel(x) > 0', 'errorTag', ...
    'wrongInput:emptyArray', 'errorMessage', ...
    'Each array must be not empty.');

modgen.common.checkvar( sumEllArr,'all(~x(:).isEmpty())','errorTag', ...
    'wrongInput:emptyEllipsoid', 'errorMessage', ...
    'Array should not have empty ellipsoid.');

[nDim, ~]  = size(dirMat);
checkmultvar('(x1==x4)&&(x2==x4)&&all(x3(:)==x4)',...
    4,dimension(fstEll),dimension(secEll),dimension(sumEllArr),nDim,...
    'errorTag','wrongSizes','errorMessage',...
    'all ellipsoids and direction vectors must be of the same dimension');


if ~isbigger(fstEll, secEll)
    intApprEllVec = [];
    if Properties.getIsVerbose()
        if isempty(logger)
            logger=Log4jConfigurator.getLogger();
        end
        logger.info('MINKMP_IA: the resulting set is empty.');
    end
    return;
end

isVrb = Properties.getIsVerbose();
Properties.setIsVerbose(false);

nSumAmount  = numel(sumEllArr);
sumEllVec = reshape(sumEllArr, 1, nSumAmount);
absTolVal=min(fstEll.absTol, secEll.absTol);
isGoodDirVec = ~isbaddirection(fstEll, secEll, dirMat,absTolVal);
nGoodDirs = sum(isGoodDirVec);
goodDirsMat = dirMat(:,isGoodDirVec);
intApprEllVec(nGoodDirs) = feval(class(fstEll));
arrayfun(@(x) fSingleMP(x),1:nGoodDirs)

Properties.setIsVerbose(isVrb);
if intApprEllVec.isEmpty()
    if Properties.getIsVerbose()
        if isempty(logger)
            logger=Log4jConfigurator.getLogger();
        end
        logger.info('MINKMP_IA: cannot compute external approximation ');
        logger.info('for any of the specified directions.');
    end
end
    function fSingleMP(index)
        dirVec = goodDirsMat(:, index);
        intApprEllVec(index) = minksum_ia(...
            [minkdiff_ia(fstEll, secEll, dirVec), sumEllVec], dirVec);
    end
end