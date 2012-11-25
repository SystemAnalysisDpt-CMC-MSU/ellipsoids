function [X, T] = get_goodcurves(rs)
%
% GET_GOODCURVES - returns the 'good curve' trajectories of the reach set.
%
%
% Description:
% ------------
%
%  [X, T] = GET_GOODCURVES(RS)  Given reach set RS, returns X, array of cells,
%                               each representing a 'good curve' for one of the
%                               direction vectors.
%                               Corresponding time values are returned in the
%                               optional output parameter T.
%
%  WARNING! This function cannot be used with projected reach sets.
%
%
% Output:
% -------
%
%  X - array of cells, where each cell is array of points that form a 'good curve'.
%  T - array of time values.
%
%
% See also:
% ---------
%
%    REACH/REACH, GET_CENTER, GET_DIRECTIONS, GET_EA, GET_IA.
%

%
% Author:
% -------
%
%    Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
%

  import elltool.conf.Properties;

  if ~(isa(rs, 'reach'))
    error('GET_GOODCURVES: input argument must be reach set object.');
  end

  rs = rs(1, 1);
  X  = [];

  if isempty(rs)
    if nargout > 1
      T = [];
    end
    return;
  end

  if size(rs.ea_values, 2) < size(rs.ia_values, 2)
    QQ = rs.ia_values;
  else
    QQ = rs.ea_values;
  end

  if ~(isempty(rs.projection_basis))
    if size(rs.projection_basis, 2) < dimension(rs.system)
      error('GET_GOODCURVES: this function cannot be used with projected reach sets.');
    end
  end
  
  N  = size(QQ, 2);
  M  = size(rs.time_values, 2);
  LL = get_directions(rs);
  d  = dimension(rs);

  if size(LL, 2) ~= N
    error('GET_GOODCURVES: reach set object is malformed.');
  end

  for i = 1:N
    L  = LL{i};
    Q  = QQ{i};
    xx = [];
    for j = 1:M
      E  = reshape(Q(:, j), d, d);
      l  = L(:, j);
      x  = (E * l)/sqrt(l' * E * l) + rs.center_values(:, j);
      xx = [xx x];
    end
    X = [X {xx}];
  end

  if nargout > 1
    T  = rs.time_values;
  end
  
  return;
