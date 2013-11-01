function intApprEllVec = minkpm_ia(inpEllArr, inpEll, dirMat)
%
% MINKPM_IA - computation of internal approximating ellipsoids
%             of (E1 + E2 + ... + En) - E along given directions.
%             where E = inpEll,
%             E1, E2, ... En - are ellipsoids in inpEllArr.
%
%   intApprEllVec = MINKPM_IA(inpEllArr, inpEll, dirMat) - Computes
%       internal approximating ellipsoids of
%       (E1 + E2 + ... + En) - E, where E1, E2, ..., En are ellipsoids
%       in array inpEllArr, E = inpEll,
%       along directions specified by columns of matrix dirArr.
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
%   intApprEllVec: ellipsoid [1, nCols]/[0, 0] - array of internal
%       approximating ellipsoids. Empty, if for all specified
%       directions approximations cannot be computed.
%
% Example:
%   firstEllObj = ellipsoid([2; -1], [9 -5; -5 4]);
%   secEllObj = ellipsoid([-2; -1], [4 -1; -1 1]);
%   thirdEllObj = ell_unitball(2);
%   ellVec = [thirdEllObj firstEllObj];
%   dirsMat = [1 0; 1 1; 0 1; -1 1]';
%   internalEllVec = ellVec.minkpm_ia(secEllObj, dirsMat)
% 
%   internalEllVec =
%   1x3 array of ellipsoids.
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

absTol=inpEll.getAbsTol();

checkvar(inpEll,@(x) isscalar(inpEll),'errorTag','wrongInput',...
    'errorMessage','second argument must be single ellipsoid.');

[nDims, nCols]  = size(dirMat);
checkmultvar('(x2==x3) && all(x1(:)==x3)',...
    3,dimension(inpEllArr),dimension(inpEll),nDims,...
    'errorTag','wrongSizes','errorMessage',...
    'all ellipsoids and direction vectors must be of the same dimension');

fstIntApprEllVec = minksum_ia(inpEllArr, dirMat);
isVrb = Properties.getIsVerbose();
Properties.setIsVerbose(false);

intApprEllVec(nCols) = ellipsoid();
arrayfun(@(x) fSetIntApprVec(x),1:nCols);
intApprEllVec = intApprEllVec(~intApprEllVec.isEmpty());

Properties.setIsVerbose(isVrb);

if intApprEllVec.isEmpty()
    if Properties.getIsVerbose()
        if isempty(logger)
            logger=Log4jConfigurator.getLogger();
        end
        logger.info('MINKPM_IA: cannot compute internal ');
        logger.info('approximation for any');
        logger.info(' of the specified directions.')
    end
end
    function fSetIntApprVec(index)
    	fstIntApprEll = fstIntApprEllVec(index);
        dirVec = dirMat(:, index);
        if isbigger(fstIntApprEll, inpEll)
            if ~isbaddirection(fstIntApprEll, inpEll, dirVec,absTol)
                intApprEllVec(index) = ...
                    minkdiff_ia(fstIntApprEll, inpEll, dirVec);
            end
        end 
    end
end