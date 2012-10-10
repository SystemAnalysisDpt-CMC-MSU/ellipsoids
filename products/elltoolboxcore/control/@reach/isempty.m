function res = isempty(rs)
%
% ISEMPTY - checks if given reach set is an empty object.
%
%
% Description:
% ------------
%
%    RES = ISEMPTY(RS)  Checks if RS is empty reach set object.
%
%
% Output:
% -------
%
%    1 - if RS is empty object, 0 - otherwise.
%
%
% See also:
% ---------
%
%    REACH/REACH.
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
    error('ISEMPTY: input argument must be reach set object.');
  end

  [m, n] = size(rs);
  res    = [];
  
  for i = 1:m
    r = [];
    for j = 1:n
      if isempty(rs(i, j).system)
        r = [r 1];
      else
        r = [r 0];
      end
    end
    res = [res; r];
  end

  return;
