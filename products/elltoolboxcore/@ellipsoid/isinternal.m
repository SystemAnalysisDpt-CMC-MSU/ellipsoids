function res = isinternal(E, X, s)
%
% ISINTERNAL - checks if given points belong to the union or intersection
%              of ellipsoids in the given array.
%
%
% Description:
% ------------
%
%    RES = ISINTERNAL(E, X, s)  Checks if vectors specified as columns of matrix X
%                               belong to the union (s = 'u'), or
%                               intersection (s = 'i') of the ellipsoids in E.
%                               If E is a single ellipsoid, then this function
%                               checks if points in X belong to E or not.
%                               Ellipsoids in E must be of the same dimension.
%                               Column size of matrix X should match the dimension
%                               of ellipsoids.
%
%    Let E(q, Q) be an ellipsoid with center q and shape matrix Q.
%    Checking if given vector x belongs to E(q, Q) is equivalent to checking
%    if inequality
%                    <(x - q), Q^(-1)(x - q)> <= 1
%    holds.
%    If x belongs to at least one of the ellipsoids in the array, then it belongs
%    to the union of these ellipsoids. If x belongs to all ellipsoids in the array,
%    then it belongs to the intersection of these ellipsoids.
%    The default value of the specifier s = 'u'.
%
%    WARNING: be careful with degenerate ellipsoids.
%
%
% Output:
% -------
%
%    Array of 1 and/or 0.
%    1 - if vector belongs to the union or intersection of ellipsoids,
%    0 - otherwise.
%
%
% See also:
% ---------
%
%    ELLIPSOID/ELLIPSOID, DIMENSION, ISDEGENERATE, DISTANCE.
%

%
% Author:
% -------
%
%    Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
%

  import elltool.conf.Properties;


  if ~isa(E, 'ellipsoid')
    error('ISINTERNAL: first argument must be an ellipsoid, or an array of ellipsoids.');
  end

  dims = dimension(E);
  m    = min(min(dims));
  n    = max(max(dims));
  if m ~= n
    error('ISINTERNAL: ellipsoids must be of the same dimension.');
  end

  if ~(isa(X, 'double'))
    error('ISINTERNAL: second argument must be an array of vectors.');
  end

  if (nargin < 3) | ~(ischar(s))
    s = 'u';
  end

  res = [];

  if (s ~= 'u') & (s ~= 'i')
    error('ISINTERNAL: third argument is expected to be either ''u'', or ''i''.');
  end

  [k, l] = size(X);
  if k ~= n
    error('ISINTERNAL: dimensions of ellipsoid and vector do not match.');
  end

  for i = 1:l
    res = [res isinternal_sub(E, X(:, i), s, k)];
  end

  return;



%%%%%%%%
  
function res = isinternal_sub(E, x, s, k)
%
% ISINTERNAL_SUB - compute result for single vector.
%

  import elltool.conf.Properties;

  if s == 'u'
    res = 0;
  else
    res = 1;
  end

  [m, n] = size(E);
  for i = 1:m
    for j = 1:n
      q = x - E(i, j).center;
      Q = E(i, j).shape;

      if rank(Q) < k
        if Properties.getIsVerbose()
          fprintf('ISINTERNAL: Warning! There is degenerate ellipsoid in the array.\n');
          fprintf('            Regularizing...\n');
        end
        Q = regularize(Q);
      end
 
      r = q' * ell_inv(Q) * q;
      if (s == 'u')
        if (r < 1) | (abs(r - 1) < Properties.getAbsTol())
          res = 1;
          return;
        end
      else
        if (r > 1) & (abs(r - 1) > Properties.getAbsTol())
          res = 0;
          return;
        end
      end
    end
  end
  
  return;
