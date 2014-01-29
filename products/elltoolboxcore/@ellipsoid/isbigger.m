function isPositive = isbigger(fstEll, secEll)
%
% ISBIGGER - checks if one ellipsoid would contain the other if their
%            centers would coincide.
%
%   isPositive = ISBIGGER(fstEll, secEll) - Given two single ellipsoids
%       of the same dimension, fstEll and secEll, check if fstEll
%       would contain secEll inside if they were both
%       centered at origin.
%
% Input:
%   regular:
%       fstEll: ellipsoid [1, 1] - first ellipsoid.
%       secEll: ellipsoid [1, 1] - second ellipsoid
%           of the same dimention.
%
% Output:
%   isPositive: logical[1, 1], true - if ellipsoid fstEll
%       would contain secEll inside, false - otherwise.
% 
% Example:
%   firstEllObj = ellipsoid([1; 1], eye(2));
%   secEllObj = ellipsoid([1; 1], [4 -1; -1 5]);
%   isbigger(firstEllObj, secEllObj)
% 
%   ans =
% 
%        0
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 
%              2004-2008 $

import elltool.conf.Properties;
import modgen.common.checkmultvar;
import elltool.logging.Log4jConfigurator;

persistent logger;

ellipsoid.checkIsMe(fstEll,'first');
ellipsoid.checkIsMe(secEll,'second');

checkmultvar('isscalar(x1)&&isscalar(x2)&&(dimension(x1)==dimension(x2))',...
    2,fstEll,secEll,...
    'errorTag','wrongInput','errorMessage',...
    'both arguments must be single ellipsoids of the same dimension.');

[~, nFstRank] = dimension(fstEll);
[~, nSecRank] = dimension(secEll);

if nFstRank < nSecRank
    isPositive = false;
    return;
end

fstEllShMat = fstEll.shapeMat;
secEllShMat = secEll.shapeMat;
if isdegenerate(fstEll)
    if isempty(logger)
        logger=Log4jConfigurator.getLogger();
    end
    if Properties.getIsVerbose()
        logger.info('ISBIGGER: Warning! First ellipsoid is degenerate.');
        logger.info('          Regularizing...');
    end
    fstEllShMat = ellipsoid.regularize(fstEllShMat,fstEll.absTol);
end

absTolVal=min(fstEll.absTol, secEll.absTol);
tMat = ell_simdiag(fstEllShMat, secEllShMat,absTolVal);
if max(abs(diag(tMat*secEllShMat*tMat'))) < (1 + fstEll.absTol)
    isPositive = true;
else
    isPositive = false;
end
