function outEll = ellintersection_ia(inpEllArr)
%
% ELLINTERSECTION_IA - computes maximum volume ellipsoid that is contained  
%                      in the intersection of given ellipsoids.
%                      
%
% Input:
%   regular:
%       inpEllArr: ellipsoid [nDims1,nDims2,...,nDimsN] - array of  
%           ellipsoids of the same dimentions.
%
% Output:
%   outEll: ellipsoid [1, 1] - resulting maximum volume ellipsoid.
%        
% Example:
%   firstEllObj = ellipsoid([-1; 1], [2 0; 0 3]);
%   secEllObj = ellipsoid([1 2], eye(2);
%   ellVec = [firstEllObj secEllObj];
%   resEllObj = ellintersection_ia(ellVec)
%
%   resEllObj =
% 
%   Center:
%       0.1847
%       1.6914
% 
%   Shape Matrix:
%       0.0340   -0.0607
%      -0.0607    0.1713
% 
%   Nondegenerate ellipsoid in R^2.
% 
% 
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 
%              2004-2008 $
%    
%
% $Author: Vadim Kaushanskiy <vkaushanskiy@gmail.com>$ 
% $Date: 10-11-2012 $
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics 
%            and Computer Science,
%            System Analysis Department 2012 $

import modgen.common.throwerror
import elltool.conf.Properties;
import elltool.logging.Log4jConfigurator;

persistent logger;

dimsArr = dimension(inpEllArr);
minEllDim   = min(dimsArr(:));

modgen.common.checkvar( inpEllArr , 'numel(x) > 0', 'errorTag', ...
    'wrongInput:emptyArray', 'errorMessage', ...
    'Each array must be not empty.');

modgen.common.checkvar(inpEllArr,'all(~x(:).isEmpty())','errorTag', ...
    'wrongInput:emptyEllipsoid', 'errorMessage', ...
    'Array should not have empty ellipsoid.');

modgen.common.checkvar(dimsArr,'all(x(:)==x(1))',...
    'errorTag','wrongSizes',...
    'errorMessage','all ellipsoids must be of the same dimension.');

nEllipsoids = numel(inpEllArr);    
inpEllVec = reshape(inpEllArr, 1, nEllipsoids);
    
if is2EllEqCentre(inpEllVec)  
    
    firstEllObj = inpEllVec(1);
    secEllObj = inpEllVec(2);
    
    EllCenterVec = firstEllObj.getCenterVec();

    firstEllShMat = firstEllObj.getShapeMat();
    secEllShMat = secEllObj.getShapeMat();

    sqrtFirstEllShMat = ...
        gras.la.sqrtmpos(firstEllShMat,firstEllObj.getAbsTol());

    intermFirstEllShMat = eye(minEllDim);
    intermSecEllShMat = sqrtFirstEllShMat \ secEllShMat / ...
        sqrtFirstEllShMat';

    [vSecMat dSecMat] = eig(intermSecEllShMat);

    intermEllShMat = min(intermFirstEllShMat, dSecMat);

    ellMat = sqrtFirstEllShMat * vSecMat * ...
        intermEllShMat * vSecMat' * ...
             sqrtFirstEllShMat';
    ellMat = 0.5*(ellMat + ellMat');

    outEll = ellipsoid(EllCenterVec, ellMat);
else

    if Properties.getIsVerbose()
        if isempty(logger)
            logger=Log4jConfigurator.getLogger();
        end
        logger.info('Invoking CVX...');
    end
    [absTolVec, absTol] = getAbsTol(inpEllVec);
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
            ellipsoid.regularize(cvxEllMat,absTol);
    end

    ellMat = cvxEllMat * cvxEllMat';
    ellMat = 0.5*(ellMat + ellMat');

    outEll = ellipsoid(cvxEllCenterVec, ellMat);
end
end

function is2eq = is2EllEqCentre(inpEllVec)
    is2eq = false;
    
    if numel(inpEllVec) == 2
        firstEll = inpEllVec(1);
        secEll = inpEllVec(2);
        firstCenterVec = firstEll.getCenterVec();
        secCenterVec = secEll.getCenterVec();
        
        if firstEll.isMatEqualInternal(firstCenterVec, secCenterVec)
            is2eq = true;
        end
    end
end