function T = ell_valign(v, x)
%
% ELL_VALIGN - given two vectors in R^n, computes 
%              orthogonal matrix that rotates the second
%              vector making it parallel to the first one.
%
%
% Description:
% ------------
%
%    T = ELL_VALIGN(v, x) - Given vectors v and x in R^n, 
%              compute orthogonal matrix T (TT' = T'T = I),
%              such that
%                         T x = a v,
%              where a is some scalar. Actually,
%                         a = |x|/|v|
%              Here |.| denotes euclidean norm.
%
%    Let SVD of v be
%                    v = U1 * S1 * V1',
%    and SVD of x
%                    x = U2 * S2 * V2'.
%    Then we can find T from the matrix equation
%               T U2 V2' = U1 V1',
%    or,
%                T = U1 V1' (U2 V2')^(-1) = U1 V1' V2 U2'.
%
%
% Output:
% -------
%
%    T - resulting orthogonal matrix.
%
%
% See also:
% ---------
%
%    SVD, GSVD.
%

%
% Author:
% -------
%
%    Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
%

  if ~(isa(v, 'double')) || ~(isa(x, 'double'))
    error('ELL_VALIGN: both arguments must be vectors in R^n.');
  end

  [k, l] = size(v);
  [m, n] = size(x);
  if (l ~= 1) || (n ~= 1)
    error('ELL_VALIGN: both arguments must be vectors in R^n.');
  end
  if k ~= m
    error('ELL_VALIGN: both vectors must be of the same dimension.');
  end 

  [U1, ~, V1] = svd(v);
  [U2, ~, V2] = svd(x);
  T         = U1 * V1 * V2' * U2';

end
