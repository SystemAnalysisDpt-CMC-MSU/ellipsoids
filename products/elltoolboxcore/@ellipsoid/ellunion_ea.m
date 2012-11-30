function outEll = ellunion_ea(inpEllMat)
%
% ELLUNION_EA - computes minimum volume ellipsoid that contains union
%               of given ellipsoids.
%
% Input:
%   regular:
%       inpEllMat: ellipsoid [mRows, nCols] - matrix of ellipsoids
%           of the same dimentions.
%
% Output:
%   outEll: ellipsoid [1, 1] - resulting minimum volume ellipsoid.
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $
%
% $Author: Vadim Kaushanskiy <vkaushanskiy@gmail.com>$ $Date: 10-11-2012$
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $

import elltool.conf.Properties;
import modgen.common.throwerror;

ellDimensions = dimension(inpEllMat);
minEllDim   = min(min(ellDimensions));
maxEllDim   = max(max(ellDimensions));

if minEllDim ~= maxEllDim
    throwerror('wrongSizes', ...
        'ELLUNION_EA: all ellipsoids must be of the same dimension.');
end

[mRows, nCols] = size(inpEllMat);
nEllipsoids = mRows * nCols;
inpEllVec  = reshape(inpEllMat, 1, nEllipsoids);

if Properties.getIsVerbose()
    fprintf('Invoking CVX...\n');
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
