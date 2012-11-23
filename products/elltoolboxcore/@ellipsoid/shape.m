function EM = shape(E, A)
%
% SHAPE - modifies the shape matrix of the ellipsoid without changing its center.
%
%
% Description:
% ------------
%
%    EM = SHAPE(E, A)  Modifies the shape matrices of the ellipsoids in the
%                      ellipsoidal array E. The centers remain untouched -
%                      that is the difference of the function SHAPE and
%                      linear transformation A*E.
%                      A is expected to be a scalar or a square matrix
%                      of suitable dimension.
%        
%
% Output:
% -------
%
%    EM - array of modified ellipsoids.
%
%
% See also:
% ---------
%
%    ELLIPSOID/ELLIPSOID.
%

%
% Author:
% -------
%
%    Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
%

  if ~(isa(A, 'double')) || ~(isa(E, 'ellipsoid'))
    msg = sprintf('SHAPE: expected arguments are:\n');
    msg = sprintf('%s       - array of ellipsoids of the same dimension,\n', msg);
    msg = sprintf('%s       - scalar, or square matrix of the same dimension as ellipsoids.\n', msg);
    error(msg);
  end

  [m, n] = size(A); 
  if m ~= n
    error('SHAPE: only square matrices are allowed.');
  end
  d      = dimension(E);
  k      = max(max(d));
  l      = min(min(d));
  if ((k ~= l) && (n ~= 1) && (m ~= 1)) || ((k ~= n) && (n ~= 1) && (m ~= 1))
    error('SHAPE: dimensions do not match.');
  end

  EM     = [];
  [m, n] = size(E);
  for i = 1:m
    for j = 1:n
     Q    = A*(E(i, j).shape)*A';
     Q    = 0.5*(Q + Q');
     r(j) = ellipsoid(E(i, j).center, Q);
    end
    EM = [EM; r];
    clear r;
  end

end
