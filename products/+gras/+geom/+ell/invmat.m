function iMat = invmat(qMat)
% INVMAT - computes matrix inverse treating ill-conditioned matrices
% properly.
%
% Input:
%   regular:
%       qMat: double[nDim,nDim] - given square matrix
%
% Output:
%   iMat: double[nDim,nDim] - inverse matrix
%
% Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
%
[qMatDimM,qMatDimN] = size(qMat);
if qMatDimM ~= qMatDimN
    error('ELL_INV: matrix must be square.');
end
bMat = inv(qMat);
iMat = inv(bMat*qMat)*bMat; %#ok<MINV>
end