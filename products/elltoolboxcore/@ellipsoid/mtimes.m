function res = mtimes(A, E)
%
%
% Description:
% ------------
%
%    Multiplication of the ellipsoid by a matrix or a scalar.
%    If E(q,Q) is an ellipsoid, and A - matrix of suitable dimensions,
%    then
%          A E(q, Q) = E(Aq, AQA').
%        
%
%
% Output:
% -------
%
%    Resulting ellipsoid E(Aq, AQA').
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
    msg = sprintf('MTIMES: first multiplier is expected to be a matrix or a scalar,\n        and second multiplier - an ellipsoid.');
    error(msg);
  end

  [m, n] = size(A); 
  d      = dimension(E);
  k      = max(d);
  l      = min(d);
  if ((k ~= l) && (n ~= 1) && (m ~= 1)) || ((k ~= n) && (n ~= 1) && (m ~= 1))
    error('MTIMES: dimensions do not match.');
  end

  [m, n] = size(E);
  for i = 1:m
    for j = 1:n
     Q    = A*(E(i, j).shape)*A';
     Q    = 0.5*(Q + Q');
     r(j) = ellipsoid(A*(E(i, j).center), Q);
    end
    if i == 1
      res = r;
    else
      res = [res; r];
    end
    clear r;
  end

end
