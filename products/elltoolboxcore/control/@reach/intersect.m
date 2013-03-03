function res = intersect(rs, X, s)
%
% INTERSECT - checks if the reach set intersects with given ellipsoids,
%             hyperplanes or polytopes.
%
%
% Description:
% ------------
%
%    RES = INTERSECT(RS, X, s)  Given reach set RS, checks if its external (s = 'e'),
%                               or internal (s = 'i') approximation intersects
%                               with ellipsoids, hyperplanes or polytopes
%                               in the array X.
%                               Specifier s is optional parameter:
%                                  s = 'e' (default) - external approximation,
%                                  s = 'i'           - internal approximation.
%
%
% Output:
% -------
%
%    1 - if intersection is nonempty, 0 - otherwise.
%
%
% See also:
% ---------
%
%    REACH/REACH, REFINE, CUT, GET_EA, GET_IA.
%

%
% Author:
% -------
%
%    Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
%

  import elltool.conf.Properties;

  if ~(isa(rs, 'reach'))
    error('INTERSECT: first input argument must be reach set.');
  end

  if ~(isa(X, 'ellipsoid')) & ~(isa(X, 'hyperplane')) & ~(isa(X, 'polytope'))
    error('INTERSECT: second input argument must be ellipsoid, hyperplane or polytope.');
  end

  if (nargin < 3) | ~(ischar(s))
    s = 'e';
  elseif s ~= 'i'
    s = 'e';
  end

  if s == 'i'
    E   = get_ia(rs);
    res = intersect(E, X, 'u');
  else
    E   = get_ea(rs);
    n   = size(E, 2);
    res = intersect(E(:, 1), X, 'i');
    for i = 2:n
      res = res | intersect(E(:, i), X, 'i');
    end
  end

  return;
