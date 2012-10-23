function res = islti(lsys)
%
% ISLTI - checks if linear system is time-invariant.
%
%
% Description:
% ------------
%
%    RES = ISLTI(LSYS)  Checks if linear system defined by LSYS object
%                       is time-invariant.
%
%
% Output:
% -------
%
%    1 - if the system is time-invariant, 0 - otherwise.
%
%
% See also:
% ---------
%
%    LINSYS/LINSYS.
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

  if ~(isa(lsys, 'linsys'))
    error('ISLTI: input argument must be linear system object.');
  end

  [m, n] = size(lsys);
  res    = [];
  for i = 1:m
    r = [];
    for j = 1:n
      if lsys(i, j).lti > 0
        r = [r 1];
      else
        r = [r 0];
      end
      res = [res; r];
    end
  end

  return;
