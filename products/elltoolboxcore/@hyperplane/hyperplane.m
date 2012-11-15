function HA = hyperplane(v, c,varargin)
%
% HYPERPLANE - creates hyperplane structure (or array of hyperplane structures).
%
%
% Description:
% ------------
%
%    H  = HYPERPLANE(v, c)  Create hyperplane
%                               H = { x in R^n : <v, x> = c }.
%                           Here v must be vector in R^n, and c - scalar.
%    HA = HYPERPLANE(V, C)  If V is matrix in R^(n x m) and C is array of
%                           numbers of length m or 1, then m hyperplane
%                           structures are created and returned in array HA.
%
%
% Output:
% -------
%
%    H - hyperplane structure:
%           H.normal - vector in R^n,
%           H.shift  - scalar;
%        or array of such structures.
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
  neededPropNameList = {'absTol'};
  absTol =  elltool.conf.parseProp(varargin,neededPropNameList);
  if nargin == 0
    HA = hyperplane(0);
    return;
  end

  if nargin < 2
    c = 0;
  end
  
  if ~(isa(v, 'double')) | ~(isa(c, 'double'))
    error('ELL_HYPERPLANE: both arguments must be of type ''double''.');
  end
  
  [n, m] = size(v);
  [k, l] = size(c);
  if k > 1
    if m > 1
      error(sprintf('ELL_HYPERPLANE: second argument must be a scalar, or an array of %d scalars.', m));
    else
      error('ELL_HYPERPLANE: second argument must be a scalar.');
    end
  end
  if (l ~= 1) & (l ~= m)
    error(sprintf('ELL_HYPERPLANE: second argument must be a single scalar, or an array of %d scalars.', m));
  end
  
  
  import modgen.common.type.simple.checkgenext;  
  checkgenext('~(any( isnan(x1(:)) ) || any(isinf(x1(:))) || any(isnan(x2(:))) || any(isinf(x2(:))))',2,v,c); 
  
  
  if l == 1
    c(1:m) = c;
  end

  HA = [];
  for i = 1:m
    H = [];
    H.normal = real(v(:, i));
    H.shift  = real(c(i));
    H.absTol = absTol;
%    if H.shift < 0
%      H.normal = - H.normal;
%      H.shift  = - H.shift;
%    end
    if (norm(H.normal) <= absTol) & (H.shift > absTol)
      H.normal = 0;
      H.shift  = 0;
    end
    H  = class(H, 'hyperplane');
    HA = [HA H];
  end 

  return;
