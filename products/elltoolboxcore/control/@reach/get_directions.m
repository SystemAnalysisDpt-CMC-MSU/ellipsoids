function [L, T] = get_directions(rs)
%
% GET_DIRECTIONS - returns the values of direction vectors for time grid values.
%
%
% Description:
% ------------
%
%  [L, T] = GET_DIRECTIONS(RS)  Given reach set RS, returns L, array of cells,
%                               each representing a sequence of direction vector
%                               values for the corresponding time values T.
%
%
% Output:
% -------
%
%  L - array of cells, where each cell is a sequence of direction vector values
%      that correspond to the time values of the grid.
%  T - array of time values.
%
%
% See also:
% ---------
%
%    REACH/REACH, GET_CENTER, GET_GOODCURVES, GET_EA, GET_IA.
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
    error('GET_DIRECTIONS: input argument must be reach set object.');
  end

  rs = rs(1, 1);
  L  = [];

  if isempty(rs)
    if nargout > 1
      T = [];
    end
    return;
  end

  L = rs.l_values;

  if nargout > 1
    T = rs.time_values;
  end
  
  return;
