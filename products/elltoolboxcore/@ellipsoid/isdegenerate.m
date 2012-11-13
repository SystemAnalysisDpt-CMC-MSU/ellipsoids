function res = isdegenerate(E)
%
% ISDEGENERATE - checks if the ellipsoid is degenerate.
%
%
% Description:
% ------------
%
%          RES = ISDEGENERATE(E)  Returns 1 if ellipsoid E is degenerate,
%                                 0 - otherwise.
%
%
% Output:
% -------
%
%    1 - if ellipsoid E is degenerate, 0 - otherwise.
%
%
% See also:
% ---------
%
%    ELLIPSOID/ELLIPSOID, DIMENSION.
%

%
% Author:
% -------
%
%    Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
%
  import modgen.common.throwerror;  
  [m, n] = size(E);
  res = false(m, n);
  for i = 1:m
    for j = 1:n
      if isempty(E(i,j))
          throwerror('wrongInput:emptyEllipsoid','ISDEGENERATE: input argument is empty.');
      end
      if rank(E(i, j).shape) < size(E(i, j).shape, 1)
          res(i, j) = true;
      end
    end
  end

  return;
