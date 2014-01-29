function extApprEllVec = minkpm_ea(inpEllArr, inpEll, dirMat)
%
% MINKPM_EA - computation of external approximating ellipsoids
%             of (E1 + E2 + ... + En) - E along given directions.
%             where E = inpEll,
%             E1, E2, ... En - are ellipsoids in inpEllArr.
%
%   ExtApprEllVec = MINKPM_EA(inpEllArr, inpEll, dirMat) - Computes
%       external approximating ellipsoids of
%       (E1 + E2 + ... + En) - E, where E1, E2, ..., En are ellipsoids
%       in array inpEllArr, E = inpEll,
%       along directions specified by columns of matrix dirMat.
%
% Input:
%   regular:
%       inpEllArr: ellipsoid [nDims1, nDims2,...,nDimsN] -
%           array of ellipsoids of the same dimentions.
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
% Example:
%   firstEllObj = ellipsoid([2; -1], [9 -5; -5 4]);
%   secEllObj = ellipsoid([-2; -1], [4 -1; -1 1]);
%   thirdEllObj = ell_unitball(2);
%   dirsMat = [1 0; 1 1; 0 1; -1 1]';
%   ellVec = [thirdEllObj firstEllObj];
%   externalEllVec = ellVec.minkpm_ea(secEllObj, dirsMat)
% 
%   externalEllVec =
%   1x4 array of ellipsoids.
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
import modgen.common.checkvar;
import modgen.common.checkmultvar;
import elltool.conf.Properties;
import elltool.logging.Log4jConfigurator;

persistent logger;

ellipsoid.checkIsMe(inpEllArr,'first');
ellipsoid.checkIsMe(inpEll,'second');

checkvar(inpEll,@(x) isscalar(inpEll),'errorTag','wrongInput',...
    'errorMessage','second argument must be single ellipsoid.');

[nDims, nCols]  = size(dirMat);
checkmultvar('(x2==x3) && all(x1(:)==x3)',...
    3,dimension(inpEllArr),dimension(inpEll),nDims,...
    'errorTag','wrongSizes','errorMessage',...
    'all ellipsoids and direction vectors must be of the same dimension');

isVrb = Properties.getIsVerbose();
Properties.setIsVerbose(false);

% sanity check: the approximated set should be nonempty
isCheckVec = false(1,nCols);
arrayfun (@(x) fSanityCheck(x), 1:nCols);
if any(isCheckVec)
    extApprEllVec =[];
    if isVrb > 0
        if isempty(logger)
            logger=Log4jConfigurator.getLogger();
        end
        logger.info('MINKPM_EA: the resulting set is empty.');
    end
    Properties.setIsVerbose(isVrb);
else
    
    secExtApprEllVec = minksum_ea(inpEllArr, dirMat);
    absTol=min(min(secExtApprEllVec.getAbsTol()),inpEll.absTol);
    extApprEllVec(nCols) = ellipsoid();
    arrayfun(@(x) fSetExtApprEllVec(x), 1:nCols)
    extApprEllVec = extApprEllVec(~extApprEllVec.isEmpty());
    
    Properties.setIsVerbose(isVrb);
    
    if extApprEllVec.isEmpty()
        if Properties.getIsVerbose()
            if isempty(logger)
                logger=Log4jConfigurator.getLogger();
            end
            logger.info('MINKPM_EA: cannot compute external ');
            logger.info('approximation for any');
            logger.info(' of the specified directions.');
        end
    end
end
    function fSanityCheck(index)
        [svdUMat, ~, ~] = svd(dirMat(:, index));
        fstExtApprEllVec = minksum_ea(inpEllArr, svdUMat);
        isCheckVec(index) = min(fstExtApprEllVec > inpEll) < 1;
    end
    function fSetExtApprEllVec(index)
        dirVec = dirMat(:, index);
        if ~isbaddirection(secExtApprEllVec(index), inpEll, dirVec,absTol)
            extApprEllVec(index) = ...
                minkdiff_ea(secExtApprEllVec(index), inpEll, dirVec);
        end
    end
end