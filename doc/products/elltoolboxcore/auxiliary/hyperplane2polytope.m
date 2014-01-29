function P = hyperplane2polytope(HA)
%
% HYPERPLANE2POLYTOPE - converts array of hyperplanes
%                       into polytope
%
%
% Description:
% ------------
%
%    P = HYPERPLANE2POLYTOPE(HA)  Given array of hyperplane objects HA, 
%                                 returns polytope object according to the
%                                 rule: if h is hyperplane from HA, with
%                                 constant c and normal n, then P will have
%                                 constraint: <x,n> <= c.
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
%    HYPERPLANE/HYPERPLANE, POLYTOPE/POLYTOPE,
%    POLYTOPE2HYPERPLANE.
%

%
% Author:
% -------
%
%    Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
%
  
  import modgen.common.throwerror;
  import elltool.conf.Properties;

  if ~(isa(HA, 'hyperplane'))
    throwerror('wrongInput:class','Input argument must be array of hyperplanes.');
  end

  dm = dimension(HA);
  mn = min(min(dm));
  mx = max(max(dm));
  if mn ~= mx
    throwerror('wrongInput:dimensions','Hyperplanes in the array must be of the same dimension.');
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

end
