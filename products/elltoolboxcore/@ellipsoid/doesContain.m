function isPosArr = doesContain(firstEllArr, secondObjArr,varargin)
% DOESCONTAIN - checks if one ellipsoid contains the other ellipsoid or
%               Polyhedron. The condition for E1 = firstEllArr to contain
%               E2 = secondEllArr is
%               min(rho(l | E1) - rho(l | E2)) > 0, subject to <l, l> = 1.
%               How checked if ellipsoid contains Polyhedron is explained in 
%               doesContainPoly.
% Input:
%   regular:
%       firstEllArr: ellipsoid [nDims1,nDims2,...,nDimsN]/[1,1] - first
%           array of ellipsoids.
%       secondObjArr: ellipsoid [nDims1,nDims2,...,nDimsN]/
%           Polyhedron[nDims1,nDims2,...,nDimsN]/[1,1] - array of the same
%           size as firstEllArr or single ellipsoid or Polyhedron.
%
%    properties:
%       mode: char[1, 1] - 'u' or 'i', go to description.
%       computeMode: char[1,] - 'highDimFast' or 'lowDimFast'. Determines, 
%           which way function is computed, when secObjArr is Polyhedron. If 
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
%using prod(size(secondEllArr)), because numel for Polyhedrons always
%returns 1, no matter what in vector of Polyhedrons, even if it is empty.
nSizeSecond = numel(secondObjArr);
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
import gras.geom.ell.invmat;
import gras.geom.ell.quadmat;
%
persistent logger;
TRY_SOLVER_LIST={'SeDuMi','SDPT3'};

[fstEllCentVec, fstEllShMat] = double(firstEll);
[secEllCentVec, secEllShMat] = double(secondEll);
if isdegenerate(firstEll)
    fstEllShMat = ellipsoid.regularize(fstEllShMat,firstEll.absTol);
end
if isdegenerate(secondEll)
    secEllShMat = ellipsoid.regularize(secEllShMat,secondEll.absTol);
end
%
invFstEllShMat = invmat(fstEllShMat);
invSecEllShMat = invmat(secEllShMat);
%
aMat = [invFstEllShMat -invFstEllShMat*fstEllCentVec;...
    (-invFstEllShMat*fstEllCentVec)' ...
      quadmat(invFstEllShMat,fstEllCentVec)-1];
bMat = [invSecEllShMat -invSecEllShMat*secEllCentVec;...
    (-invSecEllShMat*secEllCentVec)'...
      quadmat(invSecEllShMat,secEllCentVec)-1];
%
aMat = 0.5*(aMat + aMat');
bMat = 0.5*(bMat + bMat');
if Properties.getIsVerbose()
    if isempty(logger)
        logger=Log4jConfigurator.getLogger();
    end
    logger.info('Invoking CVX...');
end
nSolvers=length(TRY_SOLVER_LIST);
for iSolver=1:nSolvers
    cvx_begin sdp
    cvx_solver(TRY_SOLVER_LIST{iSolver});
    variable cvxxVec(1, 1)
    aMat <= cvxxVec*bMat %#ok<NOPRT>
    cvxxVec >= 0 %#ok<NOPRT>
    cvx_end
    if strcmp(cvx_status,'Failed')
        isCVXFailed=true;
    else
        isCVXFailed=false;
        break;
    end
    
end
if isCVXFailed
    throwerror('cvxError','Cvx failed');
else
    if strcmp(cvx_status,'Solved') ...
            || strcmp(cvx_status, 'Inaccurate/Solved')
        res = true;
    else
        res = false;
    end
end
end