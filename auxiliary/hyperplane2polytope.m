function P = hyperplane2polytope(HA)
%
% HYPERPLANE2POLYTOPE - converts array of hyperplanes into polytope
%
%
% Description:
% ------------
%
%    P = HYPERPLANE2POLYTOPE(HA)  Given array of hyperplane objects HA, 
%                                 returns polytope object.
%                                 Requires Multi-Parametric Toolbox.
%
%
% Output:
% -------
%
%    P - polytope.
%
%
% See also:
% ---------
%
%    HYPERPLANE/HYPERPLANE, POLYTOPE/POLYTOPE, POLYTOPE2HYPERPLANE.
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

  if ~(isa(HA, 'hyperplane'))
    error('HYPERPLANE2POLYTOPE: input argument must be array of hyperplanes.');
  end

  dm = dimension(HA);
  mn = min(min(dm));
  mx = max(max(dm));
  if mn ~= mx
    error('HYPERPLANE2POLYTOPE: hyperplanes in the array must be of the same dimension.');
  end
  
  [m, n] = size(HA);
  A      = [];
  b      = [];
  for i = 1:m
    for j = 1:n
      [v, c] = parameters(HA(i, j));
      A      = [A; v'];
      b      = [b; c];
    end
  end

  P = polytope(A, b);

  return;
