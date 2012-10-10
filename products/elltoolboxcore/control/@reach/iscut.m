function res = iscut(rs)
%
% ISCUT - checks if given reach set object is a cut of another reach set.
%
%
% Description:
% ------------
%
%    RES = ISCUT(RS)  Checks if cut operation was performed on the reach set object RS.
%
%
% Output:
% -------
%
%    1 - if RS is a cut of the reach set, 0 - otherwise.
%
%
% See also:
% ---------
%
%    REACH/REACH, CUT.
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
    error('ISCUT: input argument must be reach set object.');
  end

  [m, n] = size(rs);
  res    = [];
  
  for i = 1:m
    r = [];
    for j = 1:n
      if rs(i, j).t0 ~= rs(i, j).time_values(1)
        r = [r 1];
      else
        r = [r 0];
      end
    end
    res = [res; r];
  end

  return;
