function isPosArr = doesContain(firstEllArr, secondObjArr,varargin)
% DOESCONTAIN - checks if one ellipsoid contains the other ellipsoid or
%               polytope. The condition for E1 = firstEllArr to contain
%               E2 = secondEllArr is
%               min(rho(l | E1) - rho(l | E2)) > 0, subject to <l, l> = 1.
%               How checked if ellipsoid contains polytope is explained in 
%               doesContainPoly.
% Input:
%   regular:
%       firstEllArr: ellipsoid [nDims1,nDims2,...,nDimsN]/[1,1] - first
%           array of ellipsoids.
%       secondObjArr: ellipsoid [nDims1,nDims2,...,nDimsN]/
%           polytope[nDims1,nDims2,...,nDimsN]/[1,1] - array of the same
%           size as firstEllArr or single ellipsoid or polytope.
%
%    properties:
%       mode: char[1, 1] - 'u' or 'i', go to description.
%       computeMode: char[1,] - 'highDimFast' or 'lowDimFast'. Determines, 
%           which way function is computed, when secObjArr is polytope. If 
%           secObjArr is ellipsoid computeMode is ignored. 'highDimFast' 
%           works  faster for  high dimensions, 'lowDimFast' for low. If
%           this property is omitted if dimension of ellipsoids is greater
%           then 10, then 'hightDimFast' is choosen, otherwise -
%           'lowDimFast'
%
% Output:
%   isPosArr: logical[nDims1,nDims2,...,nDimsN],
%       resArr(iCount) = true - firstEllArr(iCount)
%       contains secondObjArr(iCount), false - otherwise.
%
% Example:
%   firstEllObj = ellipsoid([-2; -1], [2 -1; -1 1]);
%   secEllObj = ellipsoid([-1;0], eye(2));
%   doesContain(firstEllObj,secEllObj)
%
%   ans =
%
%        0
%
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California
%              2004-2008 $
%
% $Author: Guliev Rustam <glvrst@gmail.com> $
% $Date: Dec-2012 $
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%

import elltool.conf.Properties;
import elltool.logging.Log4jConfigurator;
import modgen.common.throwerror;
import modgen.common.checkmultvar;
%
persistent logger;
checkDoesContainArgs(firstEllArr,secondObjArr);
%
isFirstScal = isscalar(firstEllArr);
isSecScal = isscalar(secondObjArr);
%
checkmultvar(strcat('x3||x4||( all(size(size(x1)) == size(size(x2)))',...
    '&& all( size(x1)==size(x2) ))'),...
    4,firstEllArr,secondObjArr,isFirstScal,isSecScal,...
    'errorTag','wrongInput',...
    'errorMessage','sizes of arrays do not match.');
%
%
nSizeFirst = numel(firstEllArr);
%using prod(size(secondEllArr)), because numel for polytopes always
%returns 1, no matter what in vector of polytopes, even if it is empty.
nSizeSecond = prod(size(secondObjArr));
%
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
%
%
if isFirstScal
    indVec = 1:nSizeSecond;
    indVec = reshape(indVec,size(secondObjArr));
    isPosArr= arrayfun(@(x) checkContaintment(1,x),indVec);
elseif isSecScal
    indVec = 1:nSizeFirst;
    indVec = reshape(indVec,size(firstEllArr));
    isPosArr = arrayfun(@(x) checkContaintment(x,1),indVec);
else
    indVec = 1:nSizeFirst;
    indVec = reshape(indVec,size(firstEllArr));
    isPosArr = arrayfun(@(x) checkContaintment(x,x),indVec);
end
%
    function res = checkContaintment(firstIndex,secondIndex)
        if isa(secondObjArr,'ellipsoid')
            res = l_check_containment(firstEllArr(firstIndex),...
                secondObjArr(secondIndex));
        else
            res = doesContainPoly(firstEllArr(firstIndex),...
                secondObjArr(secondIndex),varargin);
        end
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
