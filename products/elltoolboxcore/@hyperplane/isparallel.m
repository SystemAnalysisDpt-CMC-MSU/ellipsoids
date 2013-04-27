function isPosArr = isparallel(fstHypArr, secHypArr)
%
% ISPARALLEL - check if two hyperplanes are parallel.
%
%   isResArr = ISPARALLEL(fstHypArr, secHypArr) - Checks if hyperplanes
%       in fstHypArr are parallel to hyperplanes in secHypArr and
%       returns array of true and false of the size corresponding
%       to the sizes of fstHypArr and secHypArr.
%
% Input:
%   regular:
%       fstHypArr: hyperplane [nDims1, nDims2, ...] - first array
%           of hyperplanes
%       secHypArr: hyperplane [nDims1, nDims2, ...] - second array
%           of hyperplanes
%
% Output:
%   isPosArr: logical[nDims1, nDims2, ...] -
%       isPosArr(iFstDim, iSecDim, ...) = true -
%       if fstHypArr(iFstDim, iSecDim, ...) is parallel
%       secHypArr(iFstDim, iSecDim, ...), false - otherwise.
%
% Example:
%   hypObj = hyperplane([-1 1 1; 1 1 1; 1 1 1], [2 1 0]);
%   hypObj.isparallel(hypObj(2))
% 
%   ans =
% 
%        0     1     1
% 
% 
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 
%              2004-2008 $
%
% $Author: Aushkap Nikolay <n.aushkap@gmail.com> $  
% $Date: 30-11-2012$
% $Copyright: Moscow State University,
%             Faculty of Computational Mathematics 
%             and Computer Science,
%             System Analysis Department 2012 $

import modgen.common.checkmultvar;

hyperplane.checkIsMe(fstHypArr);
hyperplane.checkIsMe(secHypArr);

checkmultvar(...
    'isequal(size(x1), size(x2)) || numel(x1) == 1 || numel(x2) == 1', ...
    2, fstHypArr, secHypArr, 'errorTag', 'wrongSizes', 'errorMessage', ...
    'Sizes of hyperplane arrays do not match.');

if (isscalar(fstHypArr))
    fstHypArr = fCopyHyp(fstHypArr,size(secHypArr));
elseif (isscalar(secHypArr))
    secHypArr = fCopyHyp(secHypArr,size(fstHypArr));
end

fstHypAbsTolArr = getAbsTol(fstHypArr);
isPosArr = arrayfun(@(x, y, z) isSingParallel(x, y, z), ...
    fstHypArr, secHypArr, fstHypAbsTolArr, 'UniformOutput', true);

    function resHypArr = fCopyHyp(hypObj, sizeVec)
        nElem=prod(sizeVec);
        resHypArr(nElem)=hyperplane();
        arrayfun(@fInitArray,1:nElem)
        resHypArr=reshape(resHypArr,sizeVec);
        function fInitArray(index)
            resHypArr(index)=hypObj;
        end
    end
end
function isPos = isSingParallel(fstHyp, secHyp, fstHypAbsTol)
%
% ISSNGLPARALLEL - check if two single hyperplanes are equal.
%
% Input:
%   regular:
%       fstHyp: hyperplane [1, 1] - first hyperplane.
%       secHyp: hyperplane [1, 1] - second hyperplane.
%       fstHypAbsTol: double[1, 1] - absTol properties.
%
% Output:
%   isPos: logical[1, 1] - isPos = true -  if fstHyp is parallel
%       secHyp, false - otherwise.
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $

fstHypNormVec = parameters(fstHyp);
secHypNormVec = parameters(secHyp);
isPos = false;
if (min(size(fstHypNormVec) == size(secHypNormVec)) >= 1)
    fstHypNormVec = fstHypNormVec/norm(fstHypNormVec);
    secHypNormVec = secHypNormVec/norm(secHypNormVec);
    if (min(size(fstHypNormVec) == size(secHypNormVec)) >= 1)
        if max(abs(fstHypNormVec - secHypNormVec)) < fstHypAbsTol
            isPos = true;
        elseif max(abs(fstHypNormVec + secHypNormVec)) < fstHypAbsTol
            isPos = true;
        end
    end
end
end