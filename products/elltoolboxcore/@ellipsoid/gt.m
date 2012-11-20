function res = gt(E1, E2)
%
%
% Description:
% ------------
%
%    See ISBIGGER for details.
%

%
% Author:
% -------
%
%    Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
%
import modgen.common.throwerror;

  if ~(isa(E1, 'ellipsoid')) | ~(isa(E2, 'ellipsoid'))
    throwerror('wrongInput', '<>: both input arguments must be ellipsoids.');
  end

  [k, l] = size(E1);
  s      = k * l;
  [m, n] = size(E2);
  t      = m * n;

  if ((k ~= m) | (l ~= n)) & (s > 1) & (t > 1)
    throwerror('wrongSizes', '<>: sizes of ellipsoidal arrays do not match.');
  end

  res = [];
  if (s > 1) & (t > 1)
    for i = 1:m
      r = [];
      for j = 1:n
        r = [r isbigger(E1(i, j), E2(i, j))];
      end
      res = [res; r];
    end
  elseif (s > 1)
    for i = 1:k
      r = [];
      for j = 1:l
        r = [r isbigger(E1(i, j), E2)];
      end
      res = [res; r];
    end
  else
    for i = 1:m
      r = [];
      for j = 1:n
        r = [r isbigger(E1, E2(i, j))];
      end
      res = [res; r];
    end
  end

  return;
