function M = mineig(E)
%
% MINEIG - return the minimal eigenvalue of the ellipsoid.
%
%
% Description:
% ------------
%
%    M = MINEIG(E)  Returns the smallest eigenvalues of ellipsoids in the array E.
%
%
% Output:
% -------
%
%    M - array of minimal eigenvalues of ellipsoids in the input array E.
%
%
% See also:
% ---------
%
%    ELLIPSOID/ELLIPSOID, ISDEGENERATE, MAXEIG.
%

%
% Author:
% -------
%
%    Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
%

  import elltool.conf.Properties;

  if ~(isa(E, 'ellipsoid'))
    error('MINEIG: input argument must be ellipsoid.')
  end

  [m, n] = size(E);
  M      = [];
  for i = 1:m
    mx = [];
    for j = 1:n
      if isdegenerate(E(i, j))
        mx = [mx 0];
      else
        mx = [mx min(eig(E(i, j).shape))];
      end
    end
    M = [M; mx];
  end

  return;
