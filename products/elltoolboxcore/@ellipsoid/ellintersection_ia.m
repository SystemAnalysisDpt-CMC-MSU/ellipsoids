function outEll = ellintersection_ia(inpEllArr)
%
% ELLINTERSECTION_IA - computes maximum volume ellipsoid that is
%                      contained in the intersection of
%                      given ellipsoids.
%
% Input:
%   regular:
%       inpEllArr: ellipsoid [nDims1,nDims2,...,nDimsN] - array of
%           ellipsoids of the same dimentions.
%
% Output:
%   outEll: ellipsoid [1, 1] - resulting maximum volume ellipsoid.
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $
%    Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
%
% $Author: Vadim Kaushanskiy <vkaushanskiy@gmail.com>$ $Date: 10-11-2012$
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $

import modgen.common.throwerror
import elltool.conf.Properties;


dimsArr = dimension(inpEllArr);
minEllDim   = min(dimsArr(:));

modgen.common.checkvar(dimsArr,'all(x(:)==x(1))',...
    'errorTag','wrongSizes',...
    'errorMessage','all ellipsoids must be of the same dimension.');

nEllipsoids = numel(inpEllArr);
inpEllVec = reshape(inpEllArr, 1, nEllipsoids);

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
-cvxDirVec <= 0;
for iEllipsoid = 1:nEllipsoids
    [inpEllcenrVec, inpEllShMat] = double(inpEllVec(iEllipsoid));
    if rank(inpEllShMat) < minEllDim
        inpEllShMat = ...
            ellipsoid.regularize(inpEllShMat,absTolVec(iEllipsoid));
    end
    invShMat     = ell_inv(inpEllShMat);
    bVec     = -invShMat * inpEllcenrVec;
    constraint     = inpEllcenrVec' * invShMat * inpEllcenrVec - 1;
    [ (-cvxDirVec(iEllipsoid)-constraint+bVec'*inpEllShMat*bVec), ...
        zeros(minEllDim,1)', (cvxEllCenterVec + inpEllShMat*bVec)' ;
        
        zeros(minEllDim,1), ...
        cvxDirVec(iEllipsoid)*eye(minEllDim), cvxEllMat;
        (cvxEllCenterVec + inpEllShMat*bVec), ...
        cvxEllMat, inpEllShMat] >= 0;
end

cvx_end

if strcmp(cvx_status,'Infeasible') || ...
        strcmp(cvx_status,'Inaccurate/Infeasible') || ...
        strcmp(cvx_status,'Failed')
    throwerror('cvxError','Cvx cannot solve the system');
end;

if rank(cvxEllMat) < minEllDim
    cvxEllMat = ...
        ellipsoid.regularize(cvxEllMat,min(absTolVec));
end

ellMat = cvxEllMat * cvxEllMat';
ellMat = 0.5*(ellMat + ellMat');

outEll = ellipsoid(cvxEllCenterVec, ellMat);
