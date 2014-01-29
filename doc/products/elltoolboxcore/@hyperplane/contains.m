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
%       myHypArr: hyperplane [nCols, 1]/[1, nCols]/
%           /[hpDim1, hpDim2, ...]/[1, 1] - array of hyperplanes
%           of the same dimentions nDims.
%       xArr: double[nDims, nCols]/[nDims, hpDim1, hpDim2, ...]/
%           /[nDims, 1]/[nDims, nVecArrDim1, nVecArrDim2, ...] - array
%           whose columns represent the vectors needed to be checked.
%
%           note: if size of myHypArr is [hpDim1, hpDim2, ...], then
%               size of xArr is [nDims, hpDim1, hpDim2, ...]
%               or [nDims, 1], if size of myHypArr [1, 1], then xArr
%               can be any size [nDims, nVecArrDim1, nVecArrDim2, ...],
%               in this case output variable will has
%               size [1, nVecArrDim1, nVecArrDim2, ...]. If size of
%               xArr is [nDims, nCols], then size of myHypArr may be
%               [nCols, 1] or [1, nCols] or [1, 1], output variable
%               will has size respectively
%               [nCols, 1] or [1, nCols] or [nCols, 1].
%
% Output:
%   isPosArr: logical[hpDim1, hpDim2,...] /
%       / logical[1, nVecArrDim1, nVecArrDim2, ...],
%       isPosArr(iDim1, iDim2, ...) = true - myHypArr(iDim1, iDim2, ...)
%       contains xArr(:, iDim1, iDim2, ...), false - otherwise.
%
% Example:
%   hypObj = hyperplane([-1; 1]);
%   tempMat = [100 -1 2; 100 1 2];
%   hypObj.contains(tempMat)
% 
%   ans =
% 
%        1
%        0
%        1
%
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 
%              2004-2008 $
%
% $Authors:
%   Zakharov Eugene <justenterrr@gmail.com>$ 
%   $Date: 2012-10-31$
%   Aushkap Nikolay <n.aushkap@gmail.com> $  
%   $Date: 30-11-2012$
% $Copyright: Moscow State University,
%             Faculty of Computational Mathematics
%             and Computer Science,
%             System Analysis Department 2012 $

import modgen.common.checkvar;
import modgen.common.checkmultvar;

hyperplane.checkIsMe(myHypArr);

checkvar(xArr, 'isa(x,''double'')',...
    'errorTag', 'wrongInput',...
    'errorMessage', 'Second input argument must be of type double.');

checkvar(xArr, '~any(isnan(x(:)))',...
    'errorTag', 'wrongInput',...
    'errorMessage', 'Second input argument is not correct.');

nDimArr = dimension(myHypArr);
maxDim = max(nDimArr(:));
minDim = min(nDimArr(:));
%
checkmultvar('~(x1 ~= x2)', 2, maxDim, minDim, ...
    'errorTag', 'wrongInput:wrongSizes', 'errorMessage', ...
    'Hyperplanes must be of the same dimension.');
%
nDims = maxDim;
sizeXVec = size(xArr);
%
checkmultvar('~(x1 ~= x2)', 2, sizeXVec(1), nDims, ...
    'errorTag', 'wrongInput:wrongSizes', 'errorMessage', ...
    'Vector dimension does not match the dimension of hyperplanes.');

sizeHypArr = size(myHypArr);
isColumn = false;
if (numel(sizeXVec)==2)&& ~iscolumn(xArr)&&(numel(sizeHypArr)==2)&&...
        (iscolumn(myHypArr)||isrow(myHypArr))
    sizeXVec=[sizeXVec(1),1,sizeXVec(2)];
    xArr=reshape(xArr,sizeXVec);
    %
    if sizeHypArr(2)== 1
        isColumn = true;
        myHypArr = myHypArr.';
        sizeHypArr = size(myHypArr);
    end
end
%
fstCompStr = 'isequal(x1, x2) || (isscalar(x4) && ';
secCompStr = '~isempty(x3)) || (isscalar(x1))';
checkmultvar([fstCompStr secCompStr], 4, sizeXVec(2:end), ...
    sizeHypArr, xArr,  myHypArr, 'errorTag', 'wrongSizes', ...
    'errorMessage', ...
    'Array of normal vectors and array of constants has wrong sizes.');

if ((size(sizeXVec, 2) == 2) && (sizeXVec(2) == 1))
    isPosArr = arrayfun(@(x) isSingContains(x, xArr), myHypArr, ...
        'UniformOutput', true);
elseif (isscalar(myHypArr))
    otherDimVec = sizeXVec;
    otherDimVec(:, 1) = [];
    process();
    isPosArr = arrayfun(@(x) isSingContains(myHypArr, x{1}), xCArr, ...
        'UniformOutput', true);
else
    otherDimVec = size(myHypArr);
    process();
    isPosArr = arrayfun(@(x, y) isSingContains(x, y{1}), ...
        myHypArr, xCArr, 'UniformOutput', true);
end

if (isColumn)
    isPosArr = isPosArr.';
end

    function process()
        indCVec = arrayfun(@(x) ones(1, x), otherDimVec, ...
            'UniformOutput', false);
        xCArr = mat2cell(xArr, nDims, indCVec{:});
        xCArr = shiftdim(xCArr,1);
    end

end

function isPos = isSingContains(myHyp, xVec)
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
% $Authors:
%   Zakharov Eugene <justenterrr@gmail.com>$ $Date: <31 october>$
%   Aushkap Nikolay <n.aushkap@gmail.com> $  $Date: 30-11-2012$
% $Copyright: Moscow State University,
%   Faculty of Computational Mathematics and Computer Science,
%   System Analysis Department 2012 $

[hypNormVec,hypConst] = parameters(myHyp);
absTol = getAbsTol(myHyp);
isPos = false;
isFinVec = isfinite(xVec);
if all(hypNormVec(~isFinVec) == 0)
    hypNormVec = hypNormVec(isFinVec);
    xVec = xVec(isFinVec);
    if abs((hypNormVec'*xVec) - hypConst) < absTol;
        isPos = true;
    end
end

end
