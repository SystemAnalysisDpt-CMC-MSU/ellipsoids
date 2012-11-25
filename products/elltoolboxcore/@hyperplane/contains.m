function res = contains(H, X)
%
% CONTAINS - checks if given vectors belong to the hyperplane.
%
%
% Description:
% ------------
%
%    RES = CONTAINS(H, X)  Checks if vectors specified by columns of matrix X
%                          belong to hyperplanes in H.
%
%
% Output:
% -------
%
%    1 - if vector belongs to hyperplane, 0 - otherwise.
%
%
% See also:
% ---------
%
%    HYPERPLANE/HYPERPLANE.
%

%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $
%
% $Author: <Zakharov Eugene>  <justenterrr@gmail.com> $    $Date: <31 october> $
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department <2012> $

import modgen.common.type.simple.checkgenext;

if ~(isa(H, 'hyperplane'))
    error('CONTAINS: first input argument must be hyperplane.');
end

if ~(isa(X, 'double'))
    error('CONTAINS: second input argument must be of type double.');
end

checkgenext('~any(isnan(x1(:)))',1,X);

nDimVec = dimension(H);
maxDimSize = min(nDimVec(:));
minDimSize = max(nDimVec(:));
if maxDimSize ~= minDimSize
    error('CONTAINS: hyperplanes must be of the same dimension.');
end

[vecLen, nVectors] = size(X);
if vecLen ~= minDimSize
    error('CONTAINS: vector dimension does not match the dimension of hyperplanes.');
end

[nRowsH, nColsH] = size(H);
nHplanes = nRowsH * nColsH;
if (nHplanes ~= nVectors) && (nHplanes > 1) && (nVectors > 1)
    error('CONTAINS: number of vectors does not match the number of hyperplanes.');
end

if(nHplanes > 1)
    res = false(nRowsH,nColsH);
else
    res = false(1,nVectors);
end

if (nHplanes > 1) && (nVectors > 1)
    for iRow = 1:nRowsH
        for jCol = 1:nColsH
            [normVec, const] = parameters(H(iRow, jCol));
            absTol = H(iRow, jCol).absTol;
            xVec = X(:, iRow*jCol);
            res(iRow,jCol) = isContain(normVec,const,xVec,absTol);
        end
    end
elseif nHplanes > 1
    xVec = X;
    for iRow = 1:nRowsH
        for jCol = 1:nColsH
            [normVec, const] = parameters(H(iRow, jCol));
            absTol = H(iRow, jCol).absTol;
            res(iRow,jCol) = isContain(normVec,const,xVec,absTol);
        end
    end
else
    [normVec, const] = parameters(H);
    absTol = H.absTol;
    for i = 1:nVectors
        xVec = X(:, i);
        res(1,i) = isContain(normVec,const,xVec,absTol);
    end
end

function res = isContain(hplaneNormVec, hplaneConst, xVec,absTol)
res = false;
isInfComponent = (xVec == inf) | (xVec == -inf);
if any(hplaneNormVec(isInfComponent) ~= 0)
    return;
else
    hplaneNormVec = hplaneNormVec(~isInfComponent);
    xVec = xVec(~isInfComponent);
    if abs((hplaneNormVec'*xVec) - hplaneConst) < absTol;
        res = true;
    end
end


