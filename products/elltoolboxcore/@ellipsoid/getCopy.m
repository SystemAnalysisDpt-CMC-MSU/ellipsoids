function copyEllArr = getCopy(ellArr)
% GETCOPY - gives array the same size as ellArr with copies of
%           elements of ellArr.
%
% Input:
%   regular:
%       ellArr: ellipsoid[nDim1, nDim2,...] - multidimensional array
%           of ellipsoids.
%
% Output:
%   copyEllArr: ellipsoid[nDim1, nDim2,...] - multidimension array of
%       copies of elements of ellArr.
%
% $Author: Kirill Mayantsev  <kirill.mayantsev@gmail.com> $  $Date: March-2013 $
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2013 $
%
sizeCVec = num2cell(size(ellArr));
copyEllArr(sizeCVec{:}) = ellipsoid();
arrayfun(@(x) fSingleCopy(x), 1 : numel(ellArr));
%
    function fSingleCopy(index)
        curEll = ellArr(index);
        [centerVec shapeMat] = curEll.parameters();
        copyEllArr(index) = ellipsoid(centerVec, shapeMat);
    end
end