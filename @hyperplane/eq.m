function res = eq(H1, H2)
%
% Description:
% ------------
%
%    Check if two hyperplanes are the same.
%

%
% Author:
% -------
%
%    Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
%

  global ellOptions;

  if ~isstruct(ellOptions)
    evalin('base', 'ellipsoids_init;');
  end

  if ~(isa(H1, 'hyperplane')) | ~(isa(H2, 'hyperplane'))
    error('==: input arguments must be hyperplanes.');
  end

  [k, l] = size(H1);
  s      = k * l;
  [m, n] = size(H2);
  t      = m * n;

  if ((k ~= m) | (l ~= n)) & (s > 1) & (t > 1)
    error('==: sizes of hyperplane arrays do not match.');
  end

  res = [];
  if (s > 1) & (t > 1)
    for i = 1:k
      r = [];
      for j = 1:l
        r = [r l_hpeq(H1(i, j), H2(i, j))];
      end
      res = [res; r];
    end
  elseif (s > 1)
    for i = 1:k
      r = [];
      for j = 1:l
        r = [r l_hpeq(H1(i, j), H2)];
      end
      res = [res; r];
    end
  else
    for i = 1:m
      r = [];
      for j = 1:n
        r = [r l_hpeq(H1, H2(i, j))];
      end
      res = [res; r];
    end
  end

  return;





%%%%%%%%

function res = l_hpeq(H1, H2)
%
% L_HPEQ - check if two single hyperplanes are equal.
%

  global ellOptions;

  [x, a] = parameters(H1);
  [y, b] = parameters(H2);
  res    = 0;
  if min(size(x) == size(y)) < 1
    return;
  end

  nx = norm(x);
  ny = norm(y);
  x  = x/nx;
  a  = a/nx;
  y  = y/ny;
  b  = b/ny;

  if a < 0
    a = -a;
    x = -x;
  end
  if b < 0
    b = -b;
    y = -y;
  end
  if abs(a - b) > ellOptions.abs_tol
    return;
  end
  if max(abs(x - y)) < ellOptions.abs_tol
    res = 1;
    return;
  end
  if a < ellOptions.abs_tol
    if max(abs(x + y)) < ellOptions.abs_tol
      res = 1;
    end
  end
    
  return;  
