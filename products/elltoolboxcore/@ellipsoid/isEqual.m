function isEqualArr = isEqual(ell1Arr, ell2Arr)
% ISEQUAL - produces logical array the same size as
%           ell1Arr/ell1Arr (if they have the same).
%           isEqualArr[iDim1, iDim2,...] is true if corresponding
%           ellipsoids are equal and false otherwise.
%
%
% Input:
%   regular:
%       ell1Arr: ellipsoid[nDim1, nDim2,...] - multidimensional array
%           of ellipsoids.
%       ell2Arr: ellipsoid[nDim1, nDim2,...] - multidimensional array
%           of ellipsoids.
%
% Output:
%   isEqualArr: logical[nDim1, nDim2,...] - multidimension array of
%       logical values. isEqualArr[iDim1, iDim2,...] is true if
%       corresponding ellipsoids are equal and false otherwise.
%
% $Author: Kirill Mayantsev  <kirill.mayantsev@gmail.com> $  $Date: March-2013 $
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2013 $
%
import modgen.common.throwerror;
%
if ~all(size(ell1Arr) == size(ell2Arr))
    throwerror('wrongInput', 'dimensions must be the same.');
end
%
isEqualArr = false(size(ell1Arr));
%
dim1Arr = ell1Arr.dimension();
dim2Arr = ell2Arr.dimension();
isEqualArr(dim1Arr == dim2Arr) = true;
arrayfun(@(x) fSingleComp(x), 1 : numel(ellArr));
%
    function fSingleComp(index)
        if isEqualArr(index)
            isEqualArr(index) = false;
            if ~ell1Arr(index).isempty() && ~ell2Arr(index).isempty()
                relTol =...
                    min(ell1Arr(index).getRelTol(),...
                    ell2Arr(index).getRelTol());
                [firstCenterVec, firstShapeMat] =...
                    ell1Arr(index).parameters();
                [secondCenterVec, secondShapeMat] =...
                    ell2Arr(index).parameters();
                isEqualArr(index) =...
                    norm(firstCenterVec - secondCenterVec) <= relTol &&...
                    norm(firstShapeMat - secondShapeMat) <= relTol;
            end
            if ell1Arr(index).isempty() && ell2Arr(index).isempty()
                isEqualArr(index) = true;
            end
        end
    end
end