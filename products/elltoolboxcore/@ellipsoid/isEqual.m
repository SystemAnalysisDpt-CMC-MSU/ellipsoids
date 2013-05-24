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
% Example:
%   firstEllObj = ellipsoid([-1; 1], [2 0; 0 3]);
%   secEllObj = ellipsoid([1 2], eye(2));
%   isEqual(firstEllObj, secEllObj)
% 
%   ans =
% 
%        0
%      
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
isEqualArr = arrayfun(@(x, y) fSingleComp(x, y), ell1Arr, ell2Arr);
%
    function isEq = fSingleComp(firstEll, secondEll)
        isEq = firstEll.dimension() == secondEll.dimension();
        if isEq
            isEq = false;
            if ~firstEll.isempty() && ~secondEll.isempty()
                relTol =...
                    min(firstEll.getRelTol(), secondEll.getRelTol());
                [firstCenterVec, firstShapeMat] = firstEll.parameters();
                [secondCenterVec, secondShapeMat] = secondEll.parameters();
                isEq =...
                    norm(firstCenterVec - secondCenterVec) <= relTol &&...
                    norm(firstShapeMat - secondShapeMat) <= relTol;
            end
            if firstEll.isempty() && secondEll.isempty()
                isEq = true;
            end
        end
    end
end