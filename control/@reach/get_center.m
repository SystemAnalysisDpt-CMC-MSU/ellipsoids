function [C, T] = get_center(rs)
%
% GET_CENTER - returns the trajectory of the center of the reach set.
%
%
% Description:
% ------------
%
%  [C, T] = GET_CENTER(RS)  Given reach set RS, returns C, array of vectors,
%                           which form the trajectory of the reach set center.
%                           Corresponding time values are returned in the
%                           optional output parameter T.
%
%
% Output:
% -------
%
%  C - array of points that form the trajectory of the reach set center.
%  T - array of time values.
%
%
% See also:
% ---------
%
%    REACH/REACH, GET_GOODCURVES, GET_DIRECTIONS, GET_EA, GET_IA.
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

  if ~(isa(rs, 'reach'))
    error('GET_CENTER: input argument must be reach set object.');
  end

  rs = rs(1, 1);
  C  = rs.center_values;

  if nargout > 1
    T = rs.time_values;
  end

  return;
