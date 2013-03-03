function [mu, T] = get_mu(rs)
%
% GET_MU - returns the values of mu parameter for systems with disturbance.
%
%
% Description:
% ------------
%
%  [MU, T] = GET_MU(RS)  Given reach set RS of the system with disturbance,
%                        returns MU, array of mu parameter values.
%                        Corresponding time values are returned in the
%                        optional output parameter T.
%
%
% Output:
% -------
%
%  MU - array of points that form the trajectory of the reach set center.
%  T  - array of time values.
%
%
% See also:
% ---------
%
%    REACH/REACH, GET_DIRECTIONS, GET_EA, GET_IA.
%

%
% Author:
% -------
%
%    Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
%

  import elltool.conf.Properties;


  if ~(isa(rs, 'reach'))
    error('GET_MU: input argument must be reach set object.');
  end

  rs = rs(1, 1);
  mu = rs.mu_values;

  if nargout > 1
    T = rs.time_values;
  end

  return;
