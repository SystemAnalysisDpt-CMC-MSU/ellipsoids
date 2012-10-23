function res = hasdisturbance(lsys)
%
% HASDISTURBANCE - checks if linear system has unknown bounded disturbance.
%
%
% Description:
% ------------
%
%    RES = HASDISTURBANCE(LSYS)  Checks if linear system defined by LSYS object
%                                has unknown bounded disturbance.
%
%
% Output:
% -------
%
%    1 - if disturbance is present, 0 - otherwise.
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
    error('HASDISTURBANCE: input argument must be linear system object.');
  end

  [m, n] = size(lsys);
  res    = [];
  for i = 1:m
    r = [];
    for j = 1:n
      if ~(isempty(lsys(i, j).disturbance)) & ...
         ~(iscell(lsys(i, j).disturbance)) & ...
         ~(isa(lsys(i, j).disturbance, 'double'))
        r = [r 1];
      else
        r = [r 0];
      end
      res = [res; r];
    end
  end

  return;
