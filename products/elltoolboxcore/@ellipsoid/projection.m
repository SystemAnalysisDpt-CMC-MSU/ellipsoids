function EP = projection(E, B)
%
% PROJECTION - computes projection of the ellipsoid onto the given subspace.
%
%
% Description:
% ------------
%
%    EP = PROJECTION(E, B)  Computes projection of the ellipsoid E onto a subspace,
%                           specified by orthogonal basis vectors B.
%                           E can be an array of ellipsoids of the same dimension.
%                           Columns of B must be orthogonal vectors.
%
%
% Output:
% -------
%
%    EP - projected ellipsoid (or array of ellipsoids), generally, of lower dimension.
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
  if ~(isa(E, 'ellipsoid')) | ~(isa(B, 'double'))
    error('PROJECTION: arguments must be array of ellipsoids and matrix with orthogonal columns.');
  end

  [k, l] = size(B);
  dims   = dimension(E);
  m      = min(dims); m = min(m);
  n      = max(dims); n = max(n);
  if (m ~= n)
    error('PROJECTION: ellipsoids in the array must be of the same dimenion.');
  end
  if (k ~= n)
    error('PROJECTION: dimension of basis vectors does not dimension of ellipsoids.');
  end
  if (k < l)
    msg = sprintf('PROJECTION: number of basis vectors must be less or equal to %d.', n);
    error(msg);
  end

  % check the orthogonality of the columns of B
  for i = 1:(l - 1)
    v = B(:, i);
    for j = (i + 1):l
      if abs(v'*B(:, j)) > E.getAbsTol()
        error('PROJECTION: basis vectors must be orthogonal.');
      end
    end
  end

  % normalize the basis vectors
  for i = 1:l
    BB(:, i) = B(:, i)/norm(B(:, i));
  end

  % compute projection
  [m, n] = size(E);
  for i = 1:m
    for j = 1:n
      r(j) = BB'*E(i, j);
    end
    if i == 1
      EP = r;
    else
      EP = [EP; r];
    end
    clear r;
  end

  return;
