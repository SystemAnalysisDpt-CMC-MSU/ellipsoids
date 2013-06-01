function outEll = ellunion_ea(inpEllArr)
%
% ELLUNION_EA - computes minimum volume ellipsoid that contains union
%               of given ellipsoids.
%
% Input:
%   regular:
%       inpEllMat: ellipsoid [nDims1,nDims2,...,nDimsN] - array of
%           ellipsoids of the same dimentions.
%
% Output:
%   outEll: ellipsoid [1, 1] - resulting minimum volume ellipsoid.
%
% Example:
%   firstEllObj = ellipsoid([-1; 1], [2 0; 0 3]);
%   secEllObj = ellipsoid([1 2], eye(2));
%   ellVec = [firstEllObj secEllObj];
%   resEllObj = ellunion_ea(ellVec)
%   resEllObj =
% 
%   Center:
%      -0.3188
%       1.2936
% 
%   Shape Matrix:
%       5.4573    1.3386
%       1.3386    4.1037
% 
%   Nondegenerate ellipsoid in R^2.
% 
% 
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 
%              2004-2008 $
%
% $Author: Vadim Kaushanskiy <vkaushanskiy@gmail.com>$ 
% $Date: 10-11-2012$
% $Copyright: Moscow State University,
%             Faculty of Computational Mathematics 
%             and Computer Science,
%             System Analysis Department 2012 $

import elltool.conf.Properties;
import modgen.common.throwerror;
import elltool.logging.Log4jConfigurator;

persistent logger;

dimsArr = dimension(inpEllArr);
minEllDim   = min(dimsArr(:));

nEllipsoids = numel(inpEllArr);
inpEllVec  = reshape(inpEllArr, 1, nEllipsoids);

modgen.common.checkvar( inpEllArr , 'numel(x) > 0', 'errorTag', ...
    'wrongInput:emptyArray', 'errorMessage', ...
    'Each array must be not empty.');

modgen.common.checkvar( inpEllArr,'all(~x(:).isEmpty())','errorTag', ...
    'wrongInput:emptyEllipsoid', 'errorMessage', ...
    'Array should not have empty ellipsoid.');

modgen.common.checkvar(dimsArr,'all(x(:)==x(1))',...
    'errorTag','wrongSizes',...
    'errorMessage','all ellipsoids must be of the same dimension.');

if Properties.getIsVerbose()
    if isempty(logger)
        logger=Log4jConfigurator.getLogger();
    end
    logger.info('Invoking CVX...\n');
end


absTolVec = getAbsTol(inpEllVec);
cvx_begin sdp
variable cvxEllMat(minEllDim, minEllDim) symmetric
variable cvxEllCenterVec(minEllDim)
variable cvxDirVec(nEllipsoids)
maximize( det_rootn( cvxEllMat ) )
subject to
-cvxDirVec <= 0
for iEllipsoid = 1:nEllipsoids
    [inpEllcenrVec, inpEllShMat] = double(inpEllVec(iEllipsoid));
    inpEllShMat = (inpEllShMat + inpEllShMat')*0.5;
    if rank(inpEllShMat) < minEllDim
        inpEllShMat = ...
            ellipsoid.regularize(inpEllShMat,absTolVec(iEllipsoid));
    end
    
    inpEllShMat     = inv(inpEllShMat);
    inpEllShMat = (inpEllShMat + inpEllShMat')*0.5;
    bVec    = -inpEllShMat * inpEllcenrVec;
    constraint    = inpEllcenrVec' * inpEllShMat * inpEllcenrVec - 1;
    
    [ -(cvxEllMat - cvxDirVec(iEllipsoid)*inpEllShMat), ...
        -(cvxEllCenterVec- cvxDirVec(iEllipsoid)*bVec), ...
        zeros(minEllDim, minEllDim);
        -(cvxEllCenterVec - cvxDirVec(iEllipsoid)*bVec)', -(- 1 - ...
        cvxDirVec(iEllipsoid)*constraint), -cvxEllCenterVec';
        zeros(minEllDim, minEllDim), -cvxEllCenterVec, cvxEllMat] >= 0;
end
cvx_end


if strcmp(cvx_status,'Infeasible') || ...
        strcmp(cvx_status,'Inaccurate/Infeasible') || ...
        strcmp(cvx_status,'Failed')
    throwerror('cvxError','Cvx cannot solve the system');
end;
ellMat = inv(cvxEllMat);
ellMat = 0.5*(ellMat + ellMat');
ellCenterVec = -ellMat * cvxEllCenterVec;

outEll = ellipsoid(ellCenterVec, ellMat);
