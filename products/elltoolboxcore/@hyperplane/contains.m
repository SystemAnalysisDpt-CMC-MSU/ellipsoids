function res = contains(H, X)
%
% CONTAINS - checks if given vectors belong to the hyperplane.
%
%
% Description:
% ------------
%
%    RES = CONTAINS(H, X)  Checks if vectors specified by columns of matrix X
%                          belong to hyperplanes in H.
%
%
% Output:
% -------
%
%    1 - if vector belongs to hyperplane, 0 - otherwise.
%
%
% See also:
% ---------
%
%    HYPERPLANE/HYPERPLANE.
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

  if ~(isa(H, 'hyperplane'))
    error('CONTAINS: first input argument must be hyperplane.');
  end

  if ~(isa(X, 'double'))
    error('CONTAINS: second input argument must be of type double.');
  end

  d = dimension(H);
  m = min(min(d));
  n = max(max(d));
  if m ~= n
    error('CONTAINS: hyperplanes must be of the same dimension.');
  end

  [k, l] = size(X);
  if k ~= n
    error('CONTAINS: vector dimension does not match the dimension of hyperplanes.');
  end

  [m, n] = size(H);
  t      = m * n;
  if (t ~= l) & (t > 1) & (l > 1)
    error('CONTAINS: number of vectors does not match the number of hyperplanes.');
  end

  res = [];
  if (t > 1) & (l > 1)
    for i = 1:m
      r = [];
      for j = 1:n
        [v, c] = parameters(H(i, j));
	x      = X(:, i*j);
        if abs((v'*x) - c) < ellOptions.abs_tol
          r = [r 1];
        else
          r = [r 0];
        end
      end
      res = [res; r];
    end
  elseif t > 1
    for i = 1:m
      r = [];
      for j = 1:n
        [v, c] = parameters(H(i, j));
        if abs((v'*X) - c) < ellOptions.abs_tol
          r = [r 1];
        else
          r = [r 0];
        end
      end
      res = [res; r];
    end
  else
    for i = 1:l
      [v, c] = parameters(H);
      x      = X(:, i);
      if abs((v'*x) - c) < ellOptions.abs_tol
        res = [res 1];
      else
        res = [res 0];
      end
    end
  end

  return;
