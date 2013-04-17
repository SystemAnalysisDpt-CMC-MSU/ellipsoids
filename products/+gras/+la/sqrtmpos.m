function qSqrtMat = sqrtmpos(qMat, absTol)
% SQRTMPOS generates a square root from positive semi-definite matrix QMat
% Input:
%     regular:
%         qMat: double[nDims, nDims]
%         absTol: double[1, 1] - tolerance for eigenvalues
%
% Output:
%   qSqrtMat: double[nDims, nDims]
%
%
%
% $Authors: Vadim Kaushanskiy  <vkaushanskiy@gmail.com> $	$Date: 2012-01-11$
%           Daniil Stepenskiy <reinkarn@gmail.com> $	$Date: 2013-03-29$
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Cybernetics,
%            System Analysis Department 2012-2013 $
import modgen.common.throwerror;

if (nargin == 1)
    absTol = 0;
end
%
[vMat, dMat]=eig(qMat);
dVec = diag(dMat);
if any(dVec < -absTol)
    throwerror('wrongInput:notPosSemDef',...
        'input matrix is expected to be positive semi-definite');
end
if (absTol == 0)
    isZeroVec = abs(dVec) < absTol;
    dVec(isZeroVec) = 0;
    dMat = diag(dVec);
end
dMat = sqrt(dMat);
qSqrtMat = vMat * dMat * vMat.';