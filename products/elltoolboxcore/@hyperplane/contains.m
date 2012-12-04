function isPosArr = contains(myHypArr, xArr)
%
% CONTAINS - checks if given vectors belong to the hyperplanes.
%
%   resMat = CONTAINS(myHyp, xMat) - Checks if vectors specified by
%       columns of matrix xMat belong to hyperplanes in myHyp.
%
% Input:
%   regular:
%       myHypArr: hyperplane [nDims1, nDims2, ...]/hyperplane [1, 1] -
%           array of hyperplanes of the same dimentions nDims.
%       xArr: double[nDims, nDims1, nDims2, ...]/double[nDims, 1] /
%           / double[nDims, mDims1, mDims2, ...] - array
%           whose columns represent the vectors needed to be checked.
%
%           note: if size of myHypArr is [nDims1, nDims2, ...], then size of
%               xArr is [nDims, nDims1, nDims2, ...] or [nDims, 1],
%               if size of myHypArr [1, 1], then xArr can be any size
%               [nDims, mDims1, mDims2, ...], in this case output
%               variable will has size [1, mDims1, mDims2, ...].
%
% Output:
%   isPosArr: logical[nDims1, nDims2,...]/logical[1, mDims1, mDims2,...]
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

myHypVec = reshape(myHypArr, [1, numel(myHypArr)]);
nDimVec = dimension(myHypVec);
maxDim = max(nDimVec(:));
minDim = min(nDimVec(:));

checkmultvar('~(x1 ~= x2)', 2, maxDim, minDim, ...
    'errorTag', 'wrongInput:wrongSizes', 'errorMessage', ...
    'Hyperplanes must be of the same dimension.');

nDims = maxDim;
sizeXVec = size(xArr);

checkmultvar('~(x1 ~= x2)', 2, sizeXVec(1), nDims, ...
    'errorTag', 'wrongInput:wrongSizes', 'errorMessage', ...
    'Vector dimension does not match the dimension of hyperplanes.');

xVec = reshape(xArr, [nDims, numel(xArr)/nDims]);
xCVec = mat2cell(xVec, nDims, ones(1, numel(xArr)/nDims));

checkmultvar('~((x1 ~= x2) && (x1 > 1) && (x2 > 1))',...
    2, size(xCVec, 2), size(myHypVec, 2), 'errorTag', ...
    'wrongInput:wrongSizes', 'errorMessage', ...
    'Number of vectors does not match the number of hyperplanes.');

if (numel(myHypArr) == 1)
    myHypVec = repmat(myHypVec, [1 size(xCVec, 2)]);
elseif (numel(xCVec) == 1)
    xCVec = repmat(xCVec, [1 size(myHypVec, 2)]);
end

isPosArr = arrayfun(@(x, y) isContain(x, y{1}), myHypVec, xCVec, ...
    'UniformOutput', true);

if (numel(myHypArr) == 1)   
    isPosArr = reshape(isPosArr, [1 sizeXVec(2:end)]);
else
    isPosArr = reshape(isPosArr, size(myHypArr));
end

end

function isPos = isContain(myHyp, xVec)
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
