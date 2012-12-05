function isPosArr = contains(myHypArr, xArr)
%
% CONTAINS - checks if given vectors belong to the hyperplanes.
%
%   isPosArr = CONTAINS(myHypArr, xArr) - Checks if vectors specified
%       by columns xArr(:, hpDim1, hpDim2, ...) belong
%       to hyperplanes in myHypArr.
%
% Input:
%   regular:
%       myHypArr: hyperplane [hpDim1, hpDim2, ...]/hyperplane [1, 1] -
%           array of hyperplanes of the same dimentions nDims.
%       xArr: double[nDims, hpDim1, hpDim2, ...]/double[nDims, 1] /
%           / double[nDims, nVecArrDim1, nVecArrDim2, ...] - array
%           whose columns represent the vectors needed to be checked.
%
%           note: if size of myHypArr is [hpDim1, hpDim2, ...], then
%               size of xArr is [nDims, hpDim1, hpDim2, ...]
%               or [nDims, 1], if size of myHypArr [1, 1], then xArr
%               can be any size [nDims, nVecArrDim1, nVecArrDim2, ...],
%               in this case output variable will has
%               size [1, nVecArrDim1, nVecArrDim2, ...].
%
% Output:
%   isPosArr: logical[hpDim1, hpDim2,...] / 
%       / logical[1, nVecArrDim1, nVecArrDim2, ...],
%       isPosArr(iDim1, iDim2, ...) = true - myHypArr(iDim1, iDim2, ...)
%       contains xArr(:, iDim1, iDim2, ...), false - otherwise.
%
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $
%
% $Author: <Zakharov Eugene>  <justenterrr@gmail.com>$ $Date: <31 october>$
% $Copyright: Moscow State University,
%   Faculty of Computational Mathematics and Computer Science,
%   System Analysis Department <2012> $
%
% $Author: Aushkap Nikolay <n.aushkap@gmail.com> $  $Date: 30-11-2012$
% $Copyright: Moscow State University,
%   Faculty of Computational Mathematics and Computer Science,
%   System Analysis Department 2012 $

import modgen.common.checkvar;
import modgen.common.checkmultvar;

checkvar(myHypArr, 'isa(x,''hyperplane'')',...
    'errorTag', 'wrongInput',...
    'errorMessage', 'First input argument must be hyperplane.');

checkvar(xArr, 'isa(x,''double'')',...
    'errorTag', 'wrongInput',...
    'errorMessage', 'Second input argument must be of type double.');

checkvar(xArr, '~any(isnan(x(:)))',...
    'errorTag', 'wrongInput',...
    'errorMessage', 'Second input argument is not correct.');

nDimArr = dimension(myHypArr);
maxDim = max(nDimArr(:));
minDim = min(nDimArr(:));

checkmultvar('~(x1 ~= x2)', 2, maxDim, minDim, ...
    'errorTag', 'wrongInput:wrongSizes', 'errorMessage', ...
    'Hyperplanes must be of the same dimension.');

nDims = maxDim;
sizeXVec = size(xArr);

checkmultvar('~(x1 ~= x2)', 2, sizeXVec(1), nDims, ...
    'errorTag', 'wrongInput:wrongSizes', 'errorMessage', ...
    'Vector dimension does not match the dimension of hyperplanes.');

checkmultvar('~((x1 ~= x2) && (x1 > 1) && (x2 > 1))',...
    2, numel(xArr)/nDims, numel(myHypArr), 'errorTag', ...
    'wrongInput:wrongSizes', 'errorMessage', ...
    'Number of vectors does not match the number of hyperplanes.');

if (numel(xArr)/nDims == 1)
    isPosArr = arrayfun(@(x) iscontain(x, xArr), myHypArr, ...
        'UniformOutput', true);
elseif (numel(myHypArr) == 1)
    otherDimVec = sizeXVec;
    % otherDimVec = [nVecArrDim1, nVecArrDim2, ...]
    otherDimVec(:, 1) = [];
    indCVec = arrayfun(@(x) ones(1, x), otherDimVec, ...
        'UniformOutput', false);
    xCArr = mat2cell(xArr, nDims, indCVec{:});
    xCArr = shiftdim(xCArr,1);
    isPosArr = arrayfun(@(x) iscontain(myHypArr, x{1}),xCArr, ...
        'UniformOutput', true);
else
    hypSizeVec = size(myHypArr);
    indCVec = arrayfun(@(x) ones(1, x), hypSizeVec, ...
        'UniformOutput', false);
    if (size(sizeXVec, 2))
        subXArr = zeros(sizeXVec(1), 1, sizeXVec(2));
        subXArr(:, 1, :) = xArr;
        xArr = subXArr;
    end
    xCArr = mat2cell(xArr, nDims, indCVec{:});
    xCArr = shiftdim(xCArr,1);
    isPosArr = arrayfun(@(x, y) iscontain(x, y{1}), myHypArr, xCArr, ...
        'UniformOutput', true);
end

end

function isPos = iscontain(myHyp, xVec)
%
% CONTAINS - checks if given vector belong to the hyperplane.
%
% Input:
%   regular:
%       myHyp: hyperplane[1, 1] - hyperplane.
%       xVec: double[nDims, 1] - vector, which needed to be checked.
%
% Output:
%   isPos: logical[1, 1] - isPos = true - myHyp contains xVec,
%       false - otherwise.
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $
%
% $Author: <Zakharov Eugene>  <justenterrr@gmail.com>$ $Date: <31 october>$
% $Copyright: Moscow State University,
%   Faculty of Computational Mathematics and Computer Science,
%   System Analysis Department <2012> $
%
% $Author: Aushkap Nikolay <n.aushkap@gmail.com> $  $Date: 30-11-2012$
% $Copyright: Moscow State University,
%   Faculty of Computational Mathematics and Computer Science,
%   System Analysis Department 2012 $

[hypNormVec,hypConst] = parameters(myHyp);
absTol = getAbsTol(myHyp);
isPos = false;
isInfComponent = (xVec == inf) | (xVec == -inf);
if any(hypNormVec(isInfComponent) ~= 0)
    return;
else
    hypNormVec = hypNormVec(~isInfComponent);
    xVec = xVec(~isInfComponent);
    if abs((hypNormVec'*xVec) - hypConst) < absTol;
        isPos = true;
    end
end

end
