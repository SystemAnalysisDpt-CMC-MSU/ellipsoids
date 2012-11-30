function outEll = ellintersection_ia(inpEllMat)
%
% ELLINTERSECTION_IA - computes maximum volume ellipsoid that is
%                      contained in the intersection of
%                      given ellipsoids.
%
% Input:
%   regular:
%       inpEllMat: ellipsoid [mRows, nCols] - matrix of ellipsoids
%           of the same dimentions.
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


ellDimensions = dimension(inpEllMat);
minEllDim   = min(min(ellDimensions));
maxEllDim   = max(max(ellDimensions));

if minEllDim ~= maxEllDim
    fstStr = 'ELLINTERSECTION_IA: all ellipsoids must ';
    secStr = 'be of the same dimension.';
    throwerror('wrongSizes', [fstStr secStr]);
end

[mRows, nCols] = size(inpEllMat);
nEllipsoids = mRows * nCols;
inpEllMat = reshape(inpEllMat, 1, nEllipsoids);

if Properties.getIsVerbose()
    fprintf('Invoking CVX...\n');
end
absTolVec = getAbsTol(inpEllMat);
cvx_begin sdp
variable cvxEllMat(minEllDim, minEllDim) symmetric
variable cvxEllCenterVec(minEllDim)
variable cvxDirVec(nEllipsoids)

maximize( det_rootn( cvxEllMat ) )
subject to
-cvxDirVec <= 0;
for iEllipsoid = 1:nEllipsoids
    [inpEllcenrVec, inpEllShMat] = double(inpEllMat(iEllipsoid));
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
        ellipsoid.regularize(cvxEllMat,min(getAbsTol(inpEllMat(:))));
end

ellMat = cvxEllMat * cvxEllMat';
ellMat = 0.5*(ellMat + ellMat');

outEll = ellipsoid(cvxEllCenterVec, ellMat);
