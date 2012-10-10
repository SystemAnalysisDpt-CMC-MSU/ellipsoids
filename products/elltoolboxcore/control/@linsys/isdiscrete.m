function res = isdiscrete(lsys)
%
% ISDISCRETE - checks if linear system is discrete-time.
%
%
% Description:
% ------------
%
%    RES = ISDISCRETE(LSYS)  Checks if linear system defined by LSYS object
%                            is discrete-time.
%
%
% Output:
% -------
%
%    1 - if the system is discrete-time, 0 - if continuous-time.
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
    error('ISDISCRETE: input argument must be linear system object.');
  end

  [m, n] = size(lsys);
  res    = [];
  for i = 1:m
    r = [];
    for j = 1:n
      if lsys(i, j).dt > 0
        r = [r 1];
      else
        r = [r 0];
      end
      res = [res; r];
    end
  end

  return;
