function res = isempty(lsys)
%
% ISEMPTY - checks if linear system object is empty.
%
%
% Description:
% ------------
%
%    RES = ISEMPTY(SYS)  Checks if linear system object is empty.
%
%
% Output:
% -------
%
%    1 - if the object is empty, 0 - otherwise.
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
    error('LINSYS: input argument must be linear system.');
  end

  [m, n] = size(lsys);
  res    = [];
  for i = 1:m
    r = [];
    for j = 1:n
      if isempty(lsys(i, j).A)
        r = [r 1];
      else
        r = [r 0];
      end
    end
    res = [res; r];
  end

  return;
