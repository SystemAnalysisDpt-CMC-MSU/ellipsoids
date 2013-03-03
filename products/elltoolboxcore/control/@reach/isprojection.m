function res = isempty(rs)
%
% ISPROJECTION - checks if given reach set object is a projection.
%
%
% Description:
% ------------
%
%    RES = ISPROJECTION(RS)  Checks if RS is projection of some reach set.
%
%
% Output:
% -------
%
%    1 - if RS is projection, 0 - otherwise.
%
%
% See also:
% ---------
%
%    REACH/REACH, PROJECTION.
%

%
% Author:
% -------
%
%    Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
%

  import elltool.conf.Properties;

  if ~(isa(rs, 'reach'))
    error('ISPROJECTION: input argument must be reach set object.');
  end

  [m, n] = size(rs);
  res    = [];
  
  for i = 1:m
    r = [];
    for j = 1:n
      if isempty(rs(i, j).projection_basis)
        r = [r 0];
      else
        r = [r 1];
      end
    end
    res = [res; r];
  end

  return;
