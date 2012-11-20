function res = eq(E1, E2)
%
%
% Description:
% ------------
%
%    Implementation of '==' operation.
%
%
% Output:
% -------
%
%    1 - if E1 = E2, 0 - otherwise.
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
  import modgen.common.throwerror;
  import gras.la.sqrtm;
  import elltool.conf.Properties;
  
  if ~(isa(E1, 'ellipsoid')) | ~(isa(E2, 'ellipsoid'))
    throwerror('wrongInput', '==: both arguments must be ellipsoids.');
  end

  [k, l] = size(E1);
  s      = k * l;
  [m, n] = size(E2);
  t      = m * n;

  if ((k ~= m) | (l ~= n)) & (s > 1) & (t > 1)
    throwerror('wrongSizes', '==: sizes of ellipsoidal arrays do not match.');
  end

  res = [];
  if (s > 1) & (t > 1)
    for i = 1:m
      r = [];
      for j = 1:n
        if dimension(E1(i, j)) ~= dimension(E2(i, j))
          r = [r 0];
          continue;
        end
        q = E1(i, j).center - E2(i, j).center;
        Q = sqrtm(E1(i, j).shape) - sqrtm(E2(i, j).shape);
        if (norm(q) > E1(i,j).relTol) | (norm(Q) > E1(i,j).relTol)
          r = [r 0];
        else
          r = [r 1];
        end
      end
      res = [res; r];
    end
  elseif (s > 1)
    for i = 1:k
      r = [];
      for j = 1:l
        if dimension(E1(i, j)) ~= dimension(E2)
          r = [r 0];
          continue;
        end
        q = E1(i, j).center - E2.center;
        Q = sqrtm(E1(i, j).shape) - sqrtm(E2.shape);
        if (norm(q) > E1(i,j).relTol) | (norm(Q) > E1(i,j).relTol)
          r = [r 0];
        else
          r = [r 1];
        end
      end
      res = [res; r];
    end
  else
    for i = 1:m
      r = [];
      for j = 1:n
        if dimension(E1) ~= dimension(E2(i, j))
          r = [r 0];
          continue;
        end
        q = E1.center - E2(i, j).center;
        Q = sqrtm(E1.shape) - sqrtm(E2(i, j).shape);
        if (norm(q) > E1.relTol) | (norm(Q) > E1.relTol)
           r = [r 0];
        else
          r = [r 1];
        end
      end
      res = [res; r];
    end
  end

  return; 
