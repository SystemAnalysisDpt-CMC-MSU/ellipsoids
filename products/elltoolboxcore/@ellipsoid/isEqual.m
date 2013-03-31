function isEqualArr = isEqual(ell1Arr, ell2Arr)
% GETCOPY - gives logical array the same size as
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
    for i = 1 : numel(ell1Arr)
        if isEqualArr(i)
            isEqualArr(i) = false;
            if ~ell1Arr(i).isempty() && ~ell2Arr(i).isempty()
                relTol =...
                    min(ell1Arr(i).getRelTol(), ell2Arr(i).getRelTol());
                [firstCenterVec, firstShapeMat] =...
                    ell1Arr(i).parameters();
                [secondCenterVec, secondShapeMat] =...
                    ell2Arr(i).parameters();
                isEqualArr(i) =...
                    norm(firstCenterVec - secondCenterVec) <= relTol &&...
                    norm(firstShapeMat - secondShapeMat) <= relTol;
            end
            if ell1Arr(i).isempty() && ell2Arr(i).isempty()
                isEqualArr(i) = true;
            end
        end
    end
end