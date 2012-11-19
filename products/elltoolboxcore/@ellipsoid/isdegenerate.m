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

  [m, n] = size(E);

  for i = 1:m
    for j = 1:n
      if rank(E(i, j).shape) < size(E(i, j).shape, 1)
        res(i, j) = 1;
      else
        res(i, j) = 0;
      end
    end
  end

  return;
