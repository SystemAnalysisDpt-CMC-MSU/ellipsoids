function [E, T] = get_ea(rs)
%
% GET_EA - returns array of ellipsoid objects representing external approximation
%          of the reach tube.
%
%
% Description:
% ------------
%
%    [E, T] = GET_EA(RS)  Given the reach set RS, returns array E of ellipsoids
%                         that form external approximation of the reach tube.
%                         Intersection of ellipsoids in every column of array E
%                         is a cut of the external approximating tube at some time.
%                         Corresponding time values are given in the optional
%                         output parameter T.
%
%
% Output:
% -------
%
%    E - mxn array of ellipsoids, where m is the number of approximations, and
%        n - number of time values for which the reach set approximation is computed.
%    T - array of corresponding time values.
%
%
% See also:
% ---------
%
%    REACH/REACH, GET_IA, GET_CENTER, GET_GOODCURVES, GET_DIRECTIONS.
%

%
% Author:
% -------
%
%    Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
%

  if ~(isa(rs, 'reach'))
    error('GET_EA: input argument must be reach set object.');
  end

  E = [];
  if nargout > 1
    T = rs.time_values;
  end
  
  if isempty(rs)
    return;
  end

  m = size(rs.ea_values, 2);
  n = size(rs.time_values, 2);
  d = dimension(rs);

  for i = 1:m
    QQ = rs.ea_values{i};
    ee = [];
    for j = 1:n
      q  = rs.center_values(:, j);
      Q  = (1 + rs.relTol()) * reshape(QQ(:, j), d, d);
      if ~gras.la.ismatposdef(Q,rs.absTol)
        Q = rs.absTol() * eye(d);
      end
      ee = [ee ellipsoid(q, Q)];
    end
    E = [E; ee];
  end

  return;
