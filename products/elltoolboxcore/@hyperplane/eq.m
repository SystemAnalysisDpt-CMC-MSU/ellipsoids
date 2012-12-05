function [isPosArr reportStrArr] = eq(fstHypArr, secHypArr)
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
%   isPosArr: logical[nDims1, nDims2, ...] - true -
%       if fstHypArr(iDim1, iDim2, ...) == secHypArr(iDim1, iDim2, ...),
%       false - otherwise. If size of fstHypArr is [1, 1], then checks
%       if fstHypArr == secHypArr(iDim1, iDim2, ...)
%       for all iDim1, iDim2, ... , and vice versa.
%   reportStrArr: cell[nDims1, nDims2, ...] of char[1, nLetters] -
%       report strings.
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

checkmultvar(...
    'isequal(size(x1), size(x2)) | numel(x1) == 1 | numel(x2) == 1', ...
    2, fstHypArr, secHypArr, 'errorTag', 'wrongSizes', 'errorMessage', ...
    'Sizes of hyperplane arrays do not match.');


if (numel(fstHypArr) == 1)
    absTolArr = getAbsTol(secHypArr);
    [isPosCArr reportStrArr] = arrayfun(@(y, z) ...
        issngleq(fstHypArr, y, z), secHypArr, absTolArr, ...
        'UniformOutput', false);
elseif (numel(secHypArr) == 1)
    absTolArr = getAbsTol(fstHypArr);
    [isPosCArr reportStrArr] = arrayfun(@(x, z) ...
        issngleq(x, secHypArr, z), fstHypArr, absTolArr, ...
        'UniformOutput', false);
else
    absTolArr = getAbsTol(fstHypArr);
    [isPosCArr reportStrArr] = arrayfun(@(x, y, z) issngleq(x, y, z), ...
        fstHypArr, secHypArr, absTolArr, 'UniformOutput', false);
end

isPosArr = cell2mat(isPosCArr);

end

function [isPos reportStr] = issngleq(fstHyp, secHyp, absTol)
%
% ISSNGLEQ - check if two single hyperplanes are equal.
%
% Input:
%   regular:
%       fstHyp: hyperplane [1, 1] - first hyperplane.
%       secHyp: hyperplane [1, 1] - second hyperplane.
%       absTol: double[1, 1] - absTol properies of hyperplane.
%
% Output:
%   isPos: logical[1, 1] - isPos = true -  if fstHyp == secHyp,
%       false - otherwise.
%   reportStr: char[1, nLetters] - report string.
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $

[fstNormVec, fstHypScal] = parameters(fstHyp);
[secNormVec, secHypScal] = parameters(secHyp);

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

fstStruct = struct('normal', fstNormVec, 'shift', fstHypScal);
secStruct = struct('normal', secNormVec, 'shift', secHypScal);

[isPos, reportStr] = ...
    modgen.struct.structcomparevec(fstStruct, secStruct, absTol);

end
