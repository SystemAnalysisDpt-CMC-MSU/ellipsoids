function res = isInside(ellArr, objArr)
% ISINSIDE - checks if given ellipsoid(or array of
%            ellipsoids) lies inside given object(or array
%            of objects): ellipsoid or polytope.
%
% Input:
%   regular:
%       ellArr: ellipsoid[nDims1,nDims2,...,nDimsN] - array
%               of ellipsoids of the same dimension.
%       objArr: ellipsoid/
%               polytope[nDims1,nDims2,...,nDimsN] of
%               objects of the same dimension. If
%               ellArr and objArr both non-scalar, than
%               size of ellArr must be the same as size of
%               objArr. Note that polytopes could be
%               combined only in vector of size [1,N].
% Output:
%   regular:
%       resArr: logical[nDims1,nDims2,...,nDimsN] array of
%               results. resArr[iDim1,...,iDimN] = true, if
%               ellArr[iDim1,...,iDimN] lies inside
%               objArr[iDim1,...,iDimN].
%
% Example:
%   firstEllObj = [0 ; 0] + ellipsoid(eye(2, 2));
%   secEllObj = [0 ; 0] + ellipsoid(2*eye(2, 2));
%   firstEllObj.isInside(secEllObj)
% 
%   ans =
% 
%        1
%
%
% $Author: <Zakharov Eugene>  <justenterrr@gmail.com> $
% $Date: <april> $
% $Copyright: Moscow State University,
% Faculty of Computational Mathematics and
% Computer Science, System Analysis Department <2013> $
%
%
import modgen.common.checkvar;
import modgen.common.checkmultvar;
import modgen.common.throwerror;
%
%Checking arguments
ellipsoid.checkIsMe(ellArr,'first');
checkvar(objArr,@(x) isa(x,'polytope') || isa(x,'ellipsoid'),...
    'wrongInput','errorMessage',...
    'second argument must be vector of ellipsoids or polytopes.');
nDimsArr  = dimension(ellArr);
[~,nCols] = size(objArr);
nPolyDimsArr = zeros(1, nCols);
for iCols = 1:nCols
    nPolyDimsArr(iCols) = dimension(objArr(iCols));
end
isEllScal = isscalar(ellArr);
isPolyScal = isscalar(objArr);
%
if ~(isEllScal || isPolyScal)
    if ~(size(size(objArr),2) == size(size(ellArr),2)) ||...
            ~all(size(objArr)==size(ellArr))
        throwerror('wrongInput','sizes of input arrays do not match.');
    end
end
checkmultvar('(x1(1)==x2(1))&&all(x1(:)==x1(1))&&all(x2(:)==x2(1))',...
    2,nDimsArr,nPolyDimsArr,...
    'errorTag','wrongInput',...
    'errorMessage','input arguments must be of the same dimension.');
%
%
absTol = ellArr.getAbsTol();
isEll = isa(objArr,'ellipsoid');
if ~isEllScal && ~isPolyScal
    indVec = getIndVec(size(ellArr));
    res = arrayfun(@(x,y)isMyEllInPoly(x,y),indVec,indVec);
elseif isPolyScal
    indVec = getIndVec(size(ellArr));
    res = arrayfun(@(x)isMyEllInPoly(x,1),indVec);
else
    indVec = getIndVec(size(objArr));
    res = arrayfun(@(x)isMyEllInPoly(1,x),indVec);
end
%
    function res = isMyEllInPoly(ellIndex,polyIndex)
        if isEll
            res = doesContain(objArr(polyIndex),ellArr(ellIndex));
        else
            [constrMat constrValVec] = double(objArr(polyIndex));
            suppFuncVec =rho(ellArr(ellIndex),constrMat');
            res = all(suppFuncVec' <= constrValVec+absTol);
        end
    end
end

function indVec = getIndVec(sizeVec)
    num = prod(sizeVec(:));
    indVec = reshape(1:num,sizeVec);
end