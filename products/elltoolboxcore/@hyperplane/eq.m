function isPosArr = eq(fstHypArr, secHypArr)
%
% EQ - check if two hyperplanes are the same.
%
% Input:
%   regular:
%       fstHypArr: hyperplane [nDims1, nDims2, ...]/hyperplane [1, 1] -
%           first array of hyperplanes.
%       secHypArr: hyperplane [nDims1, nDims2, ...]/hyperplane [1, 1] -
%           second array of hyperplanes.
%
% Output:
%    isPosArr: logical[nDims1, nDims2, ...] - true -
%       if fstHypArr(iDim1, iDim2, ...) == secHypArr(iDim1, iDim2, ...),
%       false - otherwise. If size of fstHypArr is [1, 1], then checks
%       if fstHypArr == secHypArr(iDim1, iDim2, ...)
%       for all iDim1, iDim2, ... , and vice versa.
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $
%
% $Author: Aushkap Nikolay <n.aushkap@gmail.com> $  $Date: 30-11-2012$
% $Copyright: Moscow State University,
%   Faculty of Computational Mathematics and Computer Science,
%   System Analysis Department 2012 $

import modgen.common.checkmultvar;

checkmultvar('isa(x1,''hyperplane'') && isa(x2,''hyperplane'')', 2, ...
    fstHypArr, secHypArr, 'errorTag', 'wrongInput', 'errorMessage', ...
    '==: input arguments must be hyperplanes.');

checkmultvar('isequal(size(x1), size(x2)) | numel(x1) == 1 | numel(x2) == 1', ...
    2, fstHypArr, secHypArr, 'errorTag', 'wrongSizes', 'errorMessage', ...
    'Sizes of hyperplane arrays do not match.');


if (numel(fstHypArr) == 1)
    fstHypArr = repmat(fstHypArr, size(secHypArr));
elseif (numel(secHypArr) == 1)
    secHypArr = repmat(secHypArr, size(fstHypArr));
end

isPosArr = arrayfun(@(x, y) l_hpeq(x, y), fstHypArr, secHypArr, ...
    'UniformOutput', true);

end

function isPos = l_hpeq(fstHyp, secHyp)
%
% L_HPEQ - check if two single hyperplanes are equal.
%
% Input:
%   regular:
%       fstHyp: hyperplane [1, 1] - first hyperplane.
%       secHyp: hyperplane [1, 1] - second hyperplane.
%
% Output:
%   isPos: logical[1, 1] - isPos = true -  if fstHyp == secHyp,
%       false - otherwise.
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $

[fstNormVec, fstHypScal] = parameters(fstHyp);
[secNormVec, secHypScal] = parameters(secHyp);
isPos    = false;
if min(size(fstNormVec) == size(secNormVec)) < 1
    return;
end

fstNorm = norm(fstNormVec);
secNorm = norm(secNormVec);
fstNormVec  = fstNormVec/fstNorm;
fstHypScal  = fstHypScal/fstNorm;
secNormVec  = secNormVec/secNorm;
secHypScal  = secHypScal/secNorm;

if fstHypScal < 0
    fstHypScal = -fstHypScal;
    fstNormVec = -fstNormVec;
end
if secHypScal < 0
    secHypScal = -secHypScal;
    secNormVec = -secNormVec;
end
if abs(fstHypScal - secHypScal) > fstHyp.absTol
    return;
end
if max(abs(fstNormVec - secNormVec)) < fstHyp.absTol()
    isPos = true;
    return;
end
if fstHypScal < fstHyp.absTol
    if max(abs(fstNormVec + secNormVec)) < fstHyp.absTol
        isPos = true;
    end
end

end
