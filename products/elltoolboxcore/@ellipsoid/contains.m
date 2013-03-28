function resArr = contains(firstEllArr, secondEllArr)
% CONTAINS - checks if one ellipsoid contains the other.
%            The condition for E1 = firstEllArr to contain
%            E2 = secondEllArr is
%            min(rho(l | E1) - rho(l | E2)) > 0, subject to <l, l> = 1.
%
% Input:
%   regular:
%       firstEllArr: ellipsoid [nDims1,nDims2,...,nDimsN]/[1,1] - first 
%           array of ellipsoids.
%       secondEllArr: ellipsoid [nDims1,nDims2,...,nDimsN]/[1,1] - second
%           array of ellipsoids.
%
% Output:
%   resArr: logical[nDims1,nDims2,...,nDimsN],
%       resArr(iCount) = true - firstEllArr(iCount)
%       contains secondEllArr(iCount), false - otherwise.
%
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $
%
% $Author: Guliev Rustam <glvrst@gmail.com> $   $Date: Dec-2012$
% $Copyright: Moscow State University,
%             Faculty of Computational Mathematics and Cybernetics,
%             Science, System Analysis Department 2012 $
%

import elltool.conf.Properties;
import elltool.logging.Log4jConfigurator;
import modgen.common.throwerror;
import modgen.common.checkmultvar;

persistent logger;

ellipsoid.checkIsMe(firstEllArr,'first');
ellipsoid.checkIsMe(secondEllArr,'second');

nSizeFirst = numel(firstEllArr);
nSizeSecond = numel(secondEllArr);
isFirScal = isscalar(firstEllArr);
isSecScal = isscalar(secondEllArr);

modgen.common.checkvar( firstEllArr , 'numel(x) > 0', 'errorTag', ...
    'wrongInput:emptyArray', 'errorMessage', ...
    'Each array must be not empty.');

modgen.common.checkvar( firstEllArr,'all(~isempty(x(:)))','errorTag', ...
    'wrongInput:emptyEllipsoid', 'errorMessage', ...
    'Array should not have empty ellipsoid.');

modgen.common.checkvar( secondEllArr , 'numel(x) > 0', 'errorTag', ...
    'wrongInput:emptyArray', 'errorMessage', ...
    'Each array must be not empty.');

modgen.common.checkvar( secondEllArr,'all(~isempty(x(:)))','errorTag', ...
    'wrongInput:emptyEllipsoid', 'errorMessage', ...
    'Array should not have empty ellipsoid.');

checkmultvar('all( size(x1)==size(x2) )||x3||x4',...
    4,firstEllArr,secondEllArr,isFirScal,isSecScal,...
    'errorTag','wrongInput',...
    'errorMessage','sizes of ellipsoidal arrays do not match.');

dimFirArr = dimension(firstEllArr);
dimSecArr = dimension(secondEllArr);

checkmultvar('all(x1(:)==x1(1)) && all(x2(:)==x1(1))',2,dimFirArr,dimSecArr,...
    'errorTag','wrongSizes',...
    'errorMessage','ellipsoids must be of the same dimension.');

if Properties.getIsVerbose()
    if isempty(logger)
        logger=Log4jConfigurator.getLogger();
    end
    if isFirScal && isSecScal
        logger.info('Checking ellipsoid-in-ellipsoid containment...');
    else
        logger.info(sprintf('Checking %d ellipsoid-in-ellipsoid containments...',...
            max([nSizeFirst nSizeSecond])));
    end
end

if isFirScal
    resArr = arrayfun(@(x) l_check_containment(firstEllArr,x), secondEllArr);
elseif isSecScal
    resArr = arrayfun(@(x) l_check_containment(x, secondEllArr), firstEllArr);
else
    resArr = arrayfun(@(x,y) l_check_containment(x,y), firstEllArr,secondEllArr);
end

end




%%%%%%%%

function res = l_check_containment(firstEll, secondEll)
%
% L_CHECK_CONTAINMENT - check if secondEll is inside firstEll.
%
% Input:
%   regular:
%       firstEll: ellipsoid [1, nCols] - first ellipsoid.
%       secondEll: ellipsoid [1, nCols] - second ellipsoid.
%
% Output:
%   res: logical[1,1], true - secondEll is inside firstEll, false - otherwise.
%
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $

import elltool.conf.Properties;
import elltool.logging.Log4jConfigurator;
import modgen.common.throwerror;

persistent logger;

[fstEllCentVec, fstEllShMat] = double(firstEll);
[secEllCentVec, secEllShMat] = double(secondEll);
if isdegenerate(firstEll)
    fstEllShMat = ellipsoid.regularize(fstEllShMat,firstEll.absTol);
end
if isdegenerate(secondEll)
    secEllShMat = ellipsoid.regularize(secEllShMat,secondEll.absTol);
end

invFstEllShMat = ell_inv(fstEllShMat);
invSecEllShMat = ell_inv(secEllShMat);

AMat = [invFstEllShMat -invFstEllShMat*fstEllCentVec;...
    (-invFstEllShMat*fstEllCentVec)' ...
    (fstEllCentVec'*invFstEllShMat*fstEllCentVec-1)];
BMat = [invSecEllShMat -invSecEllShMat*secEllCentVec;...
    (-invSecEllShMat*secEllCentVec)'...
    (secEllCentVec'*invSecEllShMat*secEllCentVec-1)];

AMat = 0.5*(AMat + AMat');
BMat = 0.5*(BMat + BMat');
if Properties.getIsVerbose()
    if isempty(logger)
        logger=Log4jConfigurator.getLogger();
    end
    logger.info('Invoking CVX...');
end
cvx_begin sdp
variable cvxxVec(1, 1)
AMat <= cvxxVec*BMat
cvxxVec >= 0
cvx_end

if strcmp(cvx_status,'Failed')
    throwerror('cvxError','Cvx failed');
end;
if strcmp(cvx_status,'Solved') ...
        || strcmp(cvx_status, 'Inaccurate/Solved')
    res = true;
else
    res = false;
end
end
