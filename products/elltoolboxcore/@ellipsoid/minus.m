function res = minus(E, b)
%
%
% Description:
% ------------
%
%    Operation
%              E - b
%    where E is an ellipsoid in R^n, and b - vector in R^n.
%    If E(q, Q) is an ellipsoid with center q and shape matrix Q, then
%          E(q, Q) - b = E(q - b, Q).
%
%
% Output:
% -------
%
%    Resulting ellipsoid E(q - b, Q).
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

  if ~(isa(E, 'ellipsoid'))
    error('MINUS: first argument must be ellipsoid.');
  end
  if isa(E, 'ellipsoid') && ~(isa(b, 'double'))
    error('MINUS: this operation is only permitted between ellipsoid and vector in R^n.');
  end

  d = dimension(E);
  m = max(d);
  n = min(d);
  if m ~= n
    error('MINUS: all ellipsoids in the array must be of the same dimension.');
  end

  [k, l] = size(b);
  if (l ~= 1) || (k ~= n)
    error('MINUS: vector dimension does not match.');
  end

  [m, n] = size(E);
  for i = 1:m
    for j = 1:n
      r(j)        = E(i, j);
      r(j).center = E(i, j).center - b;
    end
    if i == 1
      res = r;
    else
      res = [res; r];
    end
    clear r;
  end

end
