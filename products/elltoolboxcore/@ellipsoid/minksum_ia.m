function intApprEllVec = minksum_ia(inpEllArr, dirMat)
%
% MINKSUM_IA - computation of internal approximating ellipsoids
%              of the geometric sum of ellipsoids along given directions.
%
%   intApprEllVec = MINKSUM_IA(inpEllArr, dirMat) - Computes
%       tight internal approximating ellipsoids for the geometric
%       sum of the ellipsoids in the array inpEllArr along directions
%       specified by columns of dirMat. If ellipsoids in
%       inpEllMat are n-dimensional, matrix dirMat must have
%       dimension (n x k) where k can be arbitrarily chosen.
%       In this case, the output of the function will contain k
%       ellipsoids computed for k directions specified in dirMat.
%
%   Let inpEllMat consists from: E(q1, Q1), E(q2, Q2), ..., E(qm, Qm) - 
%   ellipsoids in R^n, and dirMat(:, iCol) = l - some vector in R^n.
%   Then tight internal approximating ellipsoid E(q, Q) for the
%   geometric sum E(q1, Q1) + E(q2, Q2) + ... + E(qm, Qm) along
%   direction l, is such that
%       rho(l | E(q, Q)) = rho(l | (E(q1, Q1) + ... + E(qm, Qm)))
%   and is defined as follows:
%       q = q1 + q2 + ... + qm,
%       Q = (S1 Q1^(1/2) + ... + Sm Qm^(1/2))' *
%           * (S1 Q1^(1/2) + ... + Sm Qm^(1/2)),
%   where S1 = I (identity), and S2, ..., Sm are orthogonal
%   matrices such that vectors
%   (S1 Q1^(1/2) l), ..., (Sm Qm^(1/2) l) are parallel.
%
% Input:
%   regular:
%       inpEllArr: ellipsoid [nDims1, nDims2,...,nDimsN] - array
%           of ellipsoids of the same dimentions.
%       dirMat: double[nDim, nCols] - matrix whose columns specify the
%           directions for which the approximations should be computed.
%
% Output:
%   intApprEllVec: ellipsoid [1, nCols] - array of internal
%       approximating ellipsoids.
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
import modgen.common.throwerror;
import modgen.common.checkmultvar;
import elltool.logging.Log4jConfigurator;

persistent logger;

ellipsoid.checkIsMe(inpEllArr,'first');

nNumel = numel(inpEllArr);
[nDims, nCols] = size(dirMat);
nDimsInpEllArr = dimension(inpEllArr);
checkmultvar('all(x2(:)==x1)',2,nDimsInpEllArr,nDims,...
    'errorTag','wrongSizes','errrorMessage',...
    'ellipsoids in the array and vector(s) must be of the same dimension.');
if isscalar(inpEllArr)
    intApprEllVec = inpEllArr;
    return;
end
isVerbose=Properties.getIsVerbose();
centVec =zeros(nDims,1);
arrayfun(@(x) fAddCenter(x),inpEllArr);
absTolArr = getAbsTol(inpEllArr);

srcMat = sqrtm(inpEllArr(1).shape) * dirMat;
%dstArr = zeros(nDims, nCols, nNumel);
sqrtShArr = zeros(nDims, nDims, nNumel);
rotArr = zeros(nDims,nDims,nNumel,nCols);
arrayfun(@(x) fSetRotArr(x), 1:nNumel);
%rotArr = gras.la.mlorthtransl(srcMat,dstArr);


intApprEllVec(1,nCols) = ellipsoid;
arrayfun(@(x) fSingleDirection(x),1:nCols);

    function fAddCenter(singEll)
        centVec = centVec + singEll.center;
    end
    
    function fSetRotArr(ellIndex)
        import gras.la.mlorthtransl;
        shMat = inpEllArr(ellIndex).shape;
        if isdegenerate(inpEllArr(ellIndex))
            if isVerbose                
                if isempty(logger)
                    logger=Log4jConfigurator.getLogger();
                end
                logger.info('MINKSUM_IA: Warning!');
                logger.info('Degenerate ellipsoid.');
                logger.info('Regularizing...')
            end
            shMat = ellipsoid.regularize(shMat, absTolArr(ellIndex));
        end
        shSqrtMat = sqrtm(shMat);
        sqrtShArr(:,:,ellIndex) = shSqrtMat;
        dstMat = shSqrtMat*dirMat;
        rotArr(:,:,ellIndex,:) = mlorthtransl(dstMat,srcMat);
    end
    
%     function fGetDstArr(index)
%         shMat = inpEllArr(index).shape;
%         if isdegenerate(inpEllArr(index))
%             if Properties.getIsVerbose()
%                 fprintf('MINKSUM_IA: Warning!');
%                 fprintf(' Degenerate ellipsoid.\n');
%                 fprintf('            Regularizing...\n')
%             end
%             shMat = ellipsoid.regularize(shMat, absTolArr(index));
%         end
%         shMat = sqrtm(shMat);
%         sqrtShArr(:,:,index) = shMat;
%         dstArr(:,:,index) = shMat*dirMat;
%     end

    function fSingleDirection(dirIndex)
        subShMat = zeros(nDims,nDims);
        arrayfun(@(x) fAddSh(x), 1:nNumel);
        intApprEllVec(dirIndex).center = centVec;
        intApprEllVec(dirIndex).shape = subShMat'*subShMat;
        
        function fAddSh(ellIndex)
            subShMat = subShMat + ...
                rotArr(:,:,ellIndex,dirIndex) * sqrtShArr(:,:,ellIndex);
        end
    end
end

