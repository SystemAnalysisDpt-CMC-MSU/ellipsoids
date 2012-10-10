function res = hasnoise(lsys)
%
% HASNOISE - checks if linear system has unknown bounded noise.
%
%
% Description:
% ------------
%
%    RES = HASNOISE(LSYS)  Checks if linear system defined by LSYS object
%                          has unknown bounded noise.
%
%
% Output:
% -------
%
%    1 - if noise is present, 0 - otherwise.
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
    error('HASNOISE: input argument must be linear system object.');
  end

  [m, n] = size(lsys);
  res    = [];
  for i = 1:m
    r = [];
    for j = 1:n
      if ~(isempty(lsys(i, j).noise)) & ...
         ~(iscell(lsys(i, j).noise)) & ...
         ~(isa(lsys(i, j).noise, 'double'))
        r = [r 1];
      else
        r = [r 0];
      end
      res = [res; r];
    end
  end

  return;
