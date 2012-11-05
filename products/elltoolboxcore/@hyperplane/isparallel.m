function res = isparallel(H1, H2)
%
% ISPARALLEL - check if two hyperplanes are parallel.
%
% Description:
% ------------
%
%    RES = ISPARALLEL(H1, H2)  Checks if hyperplanes in H1 are parallel to
%                              hyperplanes in H2 and returns array of ones
%                              and zeros of the size corresponding to the sizs
%                              of H1 and H2.
%
%
% Output:
% -------
%
%    1 - if hyperplanes are parallel, 0 - otherwise.
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

  import elltool.conf.Properties;


  if ~(isa(H1, 'hyperplane')) | ~(isa(H2, 'hyperplane'))
    error('ISPARALLEL: input arguments must be hyperplanes.');
  end

  [k, l] = size(H1);
  s      = k * l;
  [m, n] = size(H2);
  t      = m * n;

  if ((k ~= m) | (l ~= n)) & (s > 1) & (t > 1)
    error('ISPARALLEL: sizes of hyperplane arrays do not match.');
  end

  res = [];
  if (s > 1) & (t > 1)
    for i = 1:k
      r = [];
      for j = 1:l
        r = [r l_hpparallel(H1(i, j), H2(i, j))];
      end
      res = [res; r];
    end
  elseif (s > 1)
    for i = 1:k
      r = [];
      for j = 1:l
        r = [r l_hpparallel(H1(i, j), H2)];
      end
      res = [res; r];
    end
  else
    for i = 1:m
      r = [];
      for j = 1:n
        r = [r l_hpparallel(H1, H2(i, j))];
      end
      res = [res; r];
    end
  end

  return;





%%%%%%%%

function res = l_hpparallel(H1, H2)
%
% L_HPPARALLEL - check if two single hyperplanes are equal.
%

  import elltool.conf.Properties;

  x   = parameters(H1);
  y   = parameters(H2);
  res = 0;
  if min(size(x) == size(y)) < 1
    return;
  end
  
  x = x/norm(x);
  y = y/norm(y);

  if min(size(x) == size(y)) < 1
    return;
  end
  if max(abs(x - y)) < Properties.getAbsTol()
    res = 1;
  elseif max(abs(x + y)) < Properties.getAbsTol()
    res = 1;
  end

  return;  
