function [I, T] = get_ia(rs)
%
% GET_IA - returns array of ellipsoid objects representing internal approximation
%          of the reach tube.
%
%
% Description:
% ------------
%
%    [I, T] = GET_IA(RS)  Given the reach set RS, returns array I of ellipsoids
%                         that form internal approximation of the reach tube.
%                         Intersection of ellipsoids in every column of array I
%                         is a cut of the internal approximating tube at some time.
%                         Corresponding time values are given in the optional
%                         output parameter T.
%
%
% Output:
% -------
%
%    I - mxn array of ellipsoids, where m is the number of approximations, and
%        n - number of time values for which the reach set approximation is computed.
%    T - array of corresponding time values.
%
%
% See also:
% ---------
%
%    REACH/REACH, GET_EA, GET_CENTER, GET_GOODCURVES, GET_DIRECTIONS.
%

%
% Author:
% -------
%
%    Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
%

  import elltool.conf.Properties;

  if ~(isa(rs, 'reach'))
    error('GET_IA: input argument must be reach set object.');
  end

  I = [];
  if nargout > 1
    T = rs.time_values;
  end
  
  if isempty(rs)
    return;
  end

  m = size(rs.ia_values, 2);
  n = size(rs.time_values, 2);
  d = dimension(rs);

  for i = 1:m
    QQ = rs.ia_values{i};
    ee = [];
    for j = 1:n
      q  = rs.center_values(:, j);
      Q  = (1 - Properties.getRelTol()) * reshape(QQ(:, j), d, d);
      Q  = real(Q);
      if min(eig(Q)) < (- Properties.getAbsTol())
        Q = Properties.getAbsTol() * eye(d);
      end
      ee = [ee ellipsoid(q, Q)];
    end
    I = [I; ee];
  end

  return;
