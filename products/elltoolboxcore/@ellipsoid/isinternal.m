function isPositiveVec = isinternal(myEllArr, matrixOfVecMat, mode)
%
% ISINTERNAL - checks if given points belong to the union or intersection
%              of ellipsoids in the given array.
%
%   isPositiveVec = ISINTERNAL(myEllArr,  matrixOfVecMat, mode) - Checks
%       if vectors specified as columns of matrix matrixOfVecMat
%       belong to the union (mode = 'u'), or intersection (mode = 'i')
%       of the ellipsoids in myEllArr. If myEllMat is a single
%       ellipsoid, then this function checks if points in matrixOfVecMat
%       belong to myEllArr or not. Ellipsoids in E must be
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
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $

import elltool.conf.Properties;
import modgen.common.checkvar;
import modgen.common.checkmultvar;

ellipsoid.checkIsMe(myEllArr,'first');
checkvar(matrixOfVecMat,@(x) isa(matrixOfVecMat, 'double'),...
    'errorTag','wrongInput',...
    'errorMessage', 'first input argument must be ellipsoid.');

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

isPositiveVec = cellfun(@(x) isinternal_sub(myEllArr,x, mode),lCVec);

end



%%%%%%%%

function isPositive = isinternal_sub(myEllMat, xVec, mode)
%
% ISINTERNAL_SUB - compute result for single vector.
%
% Input:
%   regular:
%       myEllMat: ellipsod [mRowsOfEllMat, nColsOfEllMat] - matrix of
%           ellipsoids.
%       xVec: double [mRows, 1] - matrix which specifiy points.
%       mRows: double[1, 1] - dimension of ellipsoids
%           in myEllMat and xVec.
%
%   properties:
%       mode: char[1, 1] - 'u' or 'i', go to description.
%
% Output:
%    isPositive: logical[1, nColsOfVec] -
%       true - if vector belongs to the union or intersection
%       of ellipsoids, false - otherwise.
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $

import elltool.conf.Properties;

absTolMat = getAbsTol(myEllMat);

isPosMat = arrayfun(@(x,y) fSingleCase(x,y),myEllMat,absTolMat);

if mode == 'u'
    isPositive = false;
    if any(isPosMat(:))
        isPositive = true;
    end
else
    isPositive = true;
    if ~all(isPosMat(:))
        isPositive = false;
    end
end

    function isPos = fSingleCase(singEll,absTol)
        import elltool.conf.Properties;
        isPos = false;
        cVec = xVec - singEll.center;
        shMat = singEll.shape;
        
        if isdegenerate(singEll)
            if Properties.getIsVerbose()
                fstFprintStr = ...
                    'ISINTERNAL: Warning! There is degenerate ';
                secFprintStr = 'ellipsoid in the array.\n';
                fprintf([fstFprintStr secFprintStr]);
                fprintf('            Regularizing...\n');
            end
            shMat = ellipsoid.regularize(shMat, absTol);
        end
        
        r = cVec' * ell_inv(shMat) * cVec;
        if (r < 1) || (abs(r - 1) < absTol)
            isPos = true;
        end
    end
end
