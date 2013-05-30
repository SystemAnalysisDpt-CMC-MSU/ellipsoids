function isPositiveVec = isinternal(myEllArr, matrixOfVecMat, mode)
%
% ISINTERNAL - checks if given points belong to the union or intersection
%              of ellipsoids in the given array.
%
%   isPositiveVec = ISINTERNAL(myEllArr,  matrixOfVecMat, mode) - Checks
%       if vectors specified as columns of matrix matrixOfVecMat
%       belong to the union (mode = 'u'), or intersection (mode = 'i')
%       of the ellipsoids in myEllArr. If myEllArr is a single
%       ellipsoid, then this function checks if points in matrixOfVecMat
%       belong to myEllArr or not. Ellipsoids in myEllArr must be
%       of the same dimension. Column size of matrix  matrixOfVecMat
%       should match the dimension of ellipsoids.
%
%    Let myEllArr(iEll) = E(q, Q) be an ellipsoid with center q and shape
%    matrix Q. Checking if given vector matrixOfVecMat = x belongs
%    to E(q, Q) is equivalent to checking if inequality
%                    <(x - q), Q^(-1)(x - q)> <= 1
%    holds.
%    If x belongs to at least one of the ellipsoids in the array, then it
%    belongs to the union of these ellipsoids. If x belongs to all
%    ellipsoids in the array,
%    then it belongs to the intersection of these ellipsoids.
%    The default value of the specifier s = 'u'.
%
%    WARNING: be careful with degenerate ellipsoids.
%
% Input:
%   regular:
%       myEllArr: ellipsoid [nDims1,nDims2,...,nDimsN] - array
%           of ellipsoids.
%       matrixOfVecMat: double [mRows, nColsOfVec] - matrix which
%           specifiy points.
%
%   optional:
%       mode: char[1, 1] - 'u' or 'i', go to description.
%
% Output:
%    isPositiveVec: logical[1, nColsOfVec] -
%       true - if vector belongs to the union or intersection
%       of ellipsoids, false - otherwise.
%
% Example:
%   firstEllObj = ellipsoid([-2; -1], [4 -1; -1 1]);
%   secEllObj = firstEllObj + [5; 5];
%   ellVec = [firstEllObj secEllObj];
%   ellVec.isinternal([-2 3; -1 4], 'i')
% 
%   ans =
% 
%        0     0
% 
%   ellVec.isinternal([-2 3; -1 4])
% 
%   ans =
% 
%        1     1
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 
%              2004-2008 $

import elltool.conf.Properties;
import modgen.common.checkvar;
import modgen.common.checkmultvar;

ellipsoid.checkIsMe(myEllArr,'first');
modgen.common.checkvar(matrixOfVecMat,@(x) isa(x, 'double'),...
    'errorTag','wrongInput',...
    'errorMessage', 'The second input argument must be a double matrix.');

modgen.common.checkvar( myEllArr , 'numel(x) > 0', 'errorTag', ...
    'wrongInput:emptyArray', 'errorMessage', ...
    'Each array must be not empty.');

modgen.common.checkvar( myEllArr,'all(~x(:).isEmpty())','errorTag', ...
    'wrongInput:emptyEllipsoid', 'errorMessage', ...
    'Array should not have empty ellipsoid.');

if (nargin < 3) || ~(ischar(mode))
    mode = 'u';
end

checkvar(mode,@(x) (x=='u')||(x=='i'),...
    'errorTag','wrongInput','errorMessage',...
    'third argument is expected to be either ''u'', or ''i''.');

nDimsMat = dimension(myEllArr);
[mRows, nCols] = size(matrixOfVecMat);

checkmultvar('all(x1(:)==x2)',2,nDimsMat,mRows,...
    'errorTag','wrongSizes',...
    'errorMessage','dimensions mismath.');

lCVec = mat2cell(matrixOfVecMat,mRows,ones(1,nCols));

isPositiveVec = cellfun(@(x) isIntSingleVec(myEllArr,x, mode),lCVec);

end

%%%%%%%%

function isPositive = isIntSingleVec(myEllArr, xVec, mode)
%
% ISINTERNAL_SUB - compute result for single vector.
%
% Input:
%   regular:
%       myEllArr: ellipsod [nDims1,...,nDimsN] - array of
%           ellipsoids.
%       xVec: double [dimSpace, 1] - vector.
%
%   properties:
%       mode: char[1, 1] - 'u' or 'i', go to description.
%
% Output:
%    isPositive: logical[1,1] -
%       true - if vector belongs to the union or intersection
%       of ellipsoids, false - otherwise.
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $

import elltool.conf.Properties;
import elltool.logging.Log4jConfigurator;
persistent logger;
absTolArr = getAbsTol(myEllArr);
isPosArr = arrayfun(@(x,y) fSingleCase(x,y),myEllArr,absTolArr);

if mode == 'u'
    isPositive = false;
    if any(isPosArr(:))
        isPositive = true;
    end
else
    isPositive = true;
    if ~all(isPosArr(:))
        isPositive = false;
    end
end
    function isPos = fSingleCase(singEll,absTol)
        import elltool.conf.Properties;
        isPos = false;
        cVec = xVec - singEll.centerVec;
        shMat = singEll.shapeMat;
        
        if isdegenerate(singEll)
            if Properties.getIsVerbose()
                if isempty(logger)
                    logger=Log4jConfigurator.getLogger();
                end
                fstFprintStr = ...
                    'ISINTERNAL: Warning! There is degenerate ';
                secFprintStr = 'ellipsoid in the array.';
                logger.info([fstFprintStr secFprintStr]);
                logger.info('            Regularizing...');
            end
            shMat = ellipsoid.regularize(shMat, absTol);
        end
        
        rVal = cVec' * ell_inv(shMat) * cVec;
        if (rVal < 1) || (abs(rVal - 1) < absTol)
            isPos = true;
        end
    end
end
