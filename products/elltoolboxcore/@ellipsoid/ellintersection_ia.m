function outEll = ellintersection_ia(inpEllArr)
% ELLINTERSECTION_IA - computes maximum volume ellipsoid that is contained  
%                     in the intersection of given ellipsoids.                      
%
% Input:
%   regular:
%       inpEllArr: ellipsoid [nDims1,nDims2,...,nDimsN] - array of  
%           ellipsoids of the same dimention.
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
import modgen.common.checkmultvar;
%
persistent logger;
%
dimsArr = dimension(inpEllArr);
minEllDim   = min(dimsArr(:));
%
modgen.common.checkvar( inpEllArr , 'numel(x) > 0', 'errorTag', ...
    'wrongInput:emptyArray', 'errorMessage', ...
    'Each array must be not empty.');
modgen.common.checkvar(inpEllArr,'all(~x(:).isEmpty())','errorTag', ...
    'wrongInput:emptyEllipsoid', 'errorMessage', ...
    'Array should not have empty ellipsoid.');
modgen.common.checkvar(dimsArr,'all(x(:)==x(1))',...
    'errorTag','wrongSizes',...
    'errorMessage','all ellipsoids must be of the same dimension.');
%
nElls = numel(inpEllArr);    
inpEllVec = reshape(inpEllArr, 1, nElls);
%    
if is2EllEqCentre(inpEllVec)  
    firstEllObj = inpEllVec(1);
    secEllObj = inpEllVec(2);
    %
    ellCenterVec = firstEllObj.getCenterVec();
    %
    firstEllShMat = firstEllObj.getShapeMat();
    secEllShMat = secEllObj.getShapeMat();
    
    [~,absTol] = firstEllObj.getAbsTol();
    checkmultvar(@(aMat, aAbsTolVal)gras.la.ismatposdef(aMat,aAbsTolVal),...
    2, firstEllShMat, absTol,...
    'errorTag','wrongInput:shapeMat',...
    'errorMessage','shapeMat matrice must not be degenerate');
    %
    sqrtFirstEllShMat = ...
        gras.la.sqrtmpos(firstEllShMat,firstEllObj.getAbsTol());
    %
    intermFirstEllShMat = eye(minEllDim);
    intermSecEllShMat = sqrtFirstEllShMat \ secEllShMat / ...
        sqrtFirstEllShMat';
    %
    [vSecMat, dSecMat] = eig(intermSecEllShMat);
    %
    intermEllShMat = min(intermFirstEllShMat, dSecMat);
    %
    ellMat = sqrtFirstEllShMat * vSecMat * ...
        intermEllShMat * vSecMat' * ...
             sqrtFirstEllShMat';
    ellMat = 0.5*(ellMat + ellMat');
    %
    outEll = ellipsoid(ellCenterVec, ellMat);
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
    %
    maximize( det_rootn( cvxEllMat ) ) %#ok<NODEF>
    subject to
    -cvxDirVec <= 0; %#ok<VUNUS>
    for iEllipsoid = 1:nElls
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
            cvxEllMat, inpEllShMat] >= 0; %#ok<VUNUS>
    end
    cvx_end
    %
    if strcmp(cvx_status,'Infeasible') || ...
            strcmp(cvx_status,'Inaccurate/Infeasible') || ...
            strcmp(cvx_status,'Failed')
        throwerror('cvxError','Cvx cannot solve the system');
    end
    %
    if rank(cvxEllMat) < minEllDim
        cvxEllMat = ...
            ellipsoid.regularize(cvxEllMat,absTol);
    end
    %
    ellMat = cvxEllMat * cvxEllMat';
    ellMat = 0.5*(ellMat + ellMat');
    %
    outEll = ellipsoid(cvxEllCenterVec, ellMat);
end
end
%
function isEq = is2EllEqCentre(inpEllVec)
    isEq = false;
    %
    if numel(inpEllVec) == 2
        firstEll = inpEllVec(1);
        secEll = inpEllVec(2);
        firstCenterVec = firstEll.getCenterVec();
        secCenterVec = secEll.getCenterVec();
        %
        if firstEll.isMatEqualInternal(firstCenterVec, secCenterVec)
            isEq = true;
        end
    end
end