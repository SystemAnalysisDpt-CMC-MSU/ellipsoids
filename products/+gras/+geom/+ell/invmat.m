function I = invmat(qMat)
% INVMAT - computes matrix inverse treating ill-conditioned matrices
% properly.
%
% Input:
%   regular:
%       qMat: double[nDim,nDim]
%
% Output:
%   I: double[nDim,nDim] - inverse matrix
%
% Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
%
[m, n] = size(qMat);
if m ~= n
    error('ELL_INV: matrix must be square.');
end
B = inv(qMat);
I = inv(B*qMat) * B;
end