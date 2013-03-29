function qSqrtMat = sqrtm(qMat, absTol)
% SQRTM generates a square root from matrix QMat
% Input:
%     regular:
%         qMat: double[nDims, nDims]
%         absTol: double[1, 1] - tolerance for eigenvalues
%
% Output:
%   QsqrtMat: double[nDims, nDims]
%
%
%
% $Author: Vadim Kaushanskiy  <vkaushanskiy@gmail.com> $	$Date: 2012-01-11$
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Cybernetics,
%            System Analysis Department 2012 $

if (nargin == 1)
    absTol = 0;
end

[vMat, dMat]=eig(qMat);
dVec = diag(dMat);
isZeroVec = abs(dVec) < absTol;
dVec(isZeroVec) = 0;
dMat = diag(dVec);
dMat = sqrt(dMat);

qSqrtMat = vMat * dMat * vMat.';
end