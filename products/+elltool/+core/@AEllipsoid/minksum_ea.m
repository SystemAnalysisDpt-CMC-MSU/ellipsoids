function extApprEllVec = minksum_ea(inpEllArr, dirMat)
%
% MINKSUM_EA - computation of external approximating ellipsoids
%              of the geometric sum of ellipsoids along given directions.
%
%   extApprEllVec = MINKSUM_EA(inpEllArr, dirMat) - Computes
%       tight external approximating ellipsoids for the geometric
%       sum of the ellipsoids in the array inpEllArr along directions
%       specified by columns of dirMat.
%       If ellipsoids in inpEllArr are n-dimensional, matrix
%       dirMat must have dimension (n x k) where k can be
%       arbitrarily chosen.
%       In this case, the output of the function will contain k
%       ellipsoids computed for k directions specified in dirMat.
%
%   Let inpEllArr consists of E(q1, Q1), E(q2, Q2), ..., E(qm, Qm) -
%   ellipsoids in R^n, and dirMat(:, iCol) = l - some vector in R^n.
%   Then tight external approximating ellipsoid E(q, Q) for the
%   geometric sum E(q1, Q1) + E(q2, Q2) + ... + E(qm, Qm)
%   along direction l, is such that
%       rho(l | E(q, Q)) = rho(l | (E(q1, Q1) + ... + E(qm, Qm)))
%   and is defined as follows:
%       q = q1 + q2 + ... + qm,
%       Q = (p1 + ... + pm)((1/p1)Q1 + ... + (1/pm)Qm),
%   where
%       p1 = sqrt(<l, Q1l>), ..., pm = sqrt(<l, Qml>).
%
% Input:
%   regular:
%       inpEllArr: ellipsoid [nDims1, nDims2,...,nDimsN] - array
%           of ellipsoids of the same dimentions.
%       dirMat: double[nDims, nCols] - matrix whose columns specify
%           the directions for which the approximations
%           should be computed.
%
% Output:
%   extApprEllVec: ellipsoid [1, nCols] - array of external
%       approximating ellipsoids.
%
% Example:
%   firstEllObj = ellipsoid([-2; -1], [4 -1; -1 1]);
%   secEllObj = ell_unitball(2);
%   ellVec = [firstEllObj secEllObj firstEllObj.inv()];
%   dirsMat = [1 0; 1 1; 0 1; -1 1]';
%   externalEllVec = ellVec.minksum_ea(dirsMat)
% 
%   externalEllVec =
%   1x4 array of ellipsoids.
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 
%              2004-2008 $
%
% $Author: Guliev Rustam <glvrst@gmail.com> $   
% $Date: Dec-2012$
% $Author: Peter Gagarinov <pgagarinov@gmail.com> $   $Date: 25-04-2013$
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%

import elltool.conf.Properties;
import modgen.common.throwerror;
import modgen.common.checkmultvar;
import elltool.logging.Log4jConfigurator;

persistent logger;

ellipsoid.checkIsMe(inpEllArr,'first');
nDimsInpEllArr = dimension(inpEllArr);

[nDims, nCols] = size(dirMat);

modgen.common.checkvar( inpEllArr , 'numel(x) > 0', 'errorTag', ...
    'wrongInput:emptyArray', 'errorMessage', ...
    'Each array must be not empty.');

modgen.common.checkvar( inpEllArr,'all(~x(:).isEmpty())','errorTag', ...
    'wrongInput:emptyEllipsoid', 'errorMessage', ...
    'Array should not have empty ellipsoid.');

modgen.common.checkvar( nDimsInpEllArr,'all(x(:)==x(1))','errorTag', ...
    'wrongSizes', 'errorMessage', ...
    'ellipsoids in the array and vector(s) must be of the same dimension.');

checkmultvar('x1(1)==x2',2,nDimsInpEllArr,nDims,...
    'errorTag','wrongSizes','errorMessage',...
    'ellipsoids in the array and vector(s) must be of the same dimension.');

if isscalar(inpEllArr)
    extApprEllVec=inpEllArr.repMat(1,nCols);
else
    centVec =zeros(nDims,1);
    arrayfun(@(x) fAddCenter(x),inpEllArr);
    %
    isVerbose=Properties.getIsVerbose();
    %
    absTolArr = getAbsTol(inpEllArr);
    extApprEllVec(1,nCols) = ellipsoid;
    arrayfun(@(x) fSingleDirection(x),1:nCols);
end
    function fAddCenter(singEll)
        centVec = centVec + singEll.centerVec;
    end
    function fSingleDirection(index)
        secCoef = 0;
        subShMat = zeros(nDims,nDims);
        dirVec = dirMat(:, index);
        arrayfun(@(x,y) fAddSh(x,y), inpEllArr, absTolArr);
        subShMat  = 0.5*secCoef*(subShMat + subShMat');
        extApprEllVec(index).centerVec = centVec;
        extApprEllVec(index).shapeMat = subShMat;
        
        function fAddSh(singEll,absTol)
            shMat = singEll.shapeMat;
            if isdegenerate(singEll)
                if isVerbose
                    if isempty(logger)
                        logger=Log4jConfigurator.getLogger();
                    end
                    logger.info('MINKSUM_EA: Warning!');
                    logger.info('Degenerate ellipsoid.');
                    logger.info('Regularizing...')
                end
                shMat = ellipsoid.regularize(shMat, absTol);
            end
            fstCoef = realsqrt(dirVec'*shMat*dirVec);
            subShMat = subShMat + ((1/fstCoef) * shMat);
            secCoef = secCoef + fstCoef;
        end
        
    end
end
