function qSqrtMat = sqrtmpos(qMat, absTol)
% SQRTMPOS generates a square root from positive semi-definite matrix QMat
% The input matrix is allowed have slightly negative input values lambda
% such that labmda>=-absTol. if lambda<=absTol it is assumed to be a zero
%
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
%           Peter Gagarinov <pgagarinov@gmail.com> $	$Date: 2013-04-17$
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
import modgen.common.throwerror;

%
if (nargin == 1)
    absTol = 0;
elseif absTol<0
    throwerror('wrongInput:absTolNegative',...
        'absTol is expected to be not-negative');
end
%
[vMat, dMat]=eig(qMat);
dVec = diag(dMat);
if any(dVec < -absTol)
    throwerror('wrongInput:notPosSemDef',...
        'input matrix is expected to be positive semi-definite');
end
%
isZeroVec = dVec <0;
dVec(isZeroVec) = 0;
dMat = diag(dVec);
dMat = realsqrt(dMat);
qSqrtMat = vMat * dMat * vMat.';