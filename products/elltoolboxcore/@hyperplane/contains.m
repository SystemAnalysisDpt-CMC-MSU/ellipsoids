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
  
  
  import modgen.common.type.simple.checkgenext;
  checkgenext('~any(isnan(x1(:)))',1,X); 

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
  
  if(t > 1)
    res = false(m,n);
  else
    res = false(1,l);
  end
  
  if (t > 1) && (l > 1)  
    for i = 1:m
      for j = 1:n
        [v, c] = parameters(H(i, j));
        x = X(:, i*j);
        res(i,j) = isContain(v,c,x);
      end
    end
  elseif t > 1
    x = X;
    for i = 1:m
      for j = 1:n
        [v, c] = parameters(H(i, j));
        res(i,j) = isContain(v,c,x);
      end
    end
  else
    [v, c] = parameters(H);
    for i = 1:l
      x = X(:, i);
      res(1,i) = isContain(v,c,x);
    end
  end

  return;
  
 function res = isContain(hyperplaneNorm, hyperplaneConst, vector)     
     global ellOptions;
     res = 0;
     indInfComponent = (vector == inf) | (vector == -inf);
     if any(hyperplaneNorm(indInfComponent) ~= 0)
         return;
     else
         hyperplaneNorm = hyperplaneNorm(~indInfComponent);
         vector = vector(~indInfComponent);
         if abs((hyperplaneNorm'*vector) - hyperplaneConst) < ellOptions.abs_tol
            res = 1;
         end
     end

             
