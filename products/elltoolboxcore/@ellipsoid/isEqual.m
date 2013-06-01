function isEqualArr = isEqual(ell1Arr, ell2Arr, varargin)
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
%   properties:
%       'isPropIncluded': makes to compare second value properties, such as
%       absTol etc.
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
[reg,isSpecVec,isPropIncluded] = ...
           modgen.common.parseparext(varargin, {'isPropIncluded'; false});
%
isEqualArr = arrayfun(@(x, y) fSingleComp(x, y, isPropIncluded), ell1Arr, ell2Arr);
%
    function isEq = fSingleComp(firstEll, secondEll, isPropIncluded)
        isEq = firstEll.dimension() == secondEll.dimension();
        if isEq
            isEq = false;
            if ~firstEll.isEmpty() && ~secondEll.isEmpty()
                relTol =...
                    min(firstEll.getRelTol(), secondEll.getRelTol());
                [firstCenterVec, firstShapeMat] = firstEll.parameters();
                [secondCenterVec, secondShapeMat] = secondEll.parameters();
                isEq =...
                    norm(firstCenterVec - secondCenterVec) <= relTol &&...
                    norm(firstShapeMat - secondShapeMat) <= relTol;
                if (isPropIncluded)
                    isEq = isEq && ...
                        firstEll.nPlot2dPoints == secondEll.nPlot2dPoints &&...
                        firstEll.nPlot3dPoints == secondEll.nPlot3dPoints &&...
                        firstEll.absTol == secondEll.absTol &&...
                        firstEll.relTol == secondEll.relTol;
                end
            end
            if firstEll.isEmpty() && secondEll.isEmpty()
                isEq = true;
            end
        end
    end
end