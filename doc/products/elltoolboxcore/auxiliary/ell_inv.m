function I = ell_inv(A)
%
% ELL_INV - computes matrix inverse treating 
%           ill-conditioned matrices properly.
%
%
% Description:
% ------------
%
%    I = ELL_INV(A)  Given two square nonsingular matrix A,
%        returns its inverse.
%
%
% Output:
% -------
%
%    I - inverse of matrix A.
%
%
% See also:
% ---------
%
%    INV, COND.
%

%
% Author:
% -------
%
%    Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
%

[m, n] = size(A);

if m ~= n
    error('ELL_INV: matrix must be square.');
end
%
B = inv(A);
I = inv(B*A) * B;
