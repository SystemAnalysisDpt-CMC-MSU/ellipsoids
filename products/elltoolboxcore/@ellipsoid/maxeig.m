function M = maxeig(E)
%
% MAXEIG - return the maximal eigenvalue of the ellipsoid.
%
%
% Description:
% ------------
%
%    M = MAXEIG(E)  Returns the largest eigenvalues of ellipsoids in the array E.
%
%
% Output:
% -------
%
%    M - array of maximal eigenvalues of ellipsoids in the input array E.
%
%
% See also:
% ---------
%
%    ELLIPSOID/ELLIPSOID, ISDEGENERATE, MINEIG.
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

  if ~(isa(E, 'ellipsoid'))
    error('MAXEIG: input argument must be ellipsoid.')
  end

  [m, n] = size(E);
  M      = [];
  for i = 1:m
    mx = [];
    for j = 1:n
      mx = [mx max(eig(E(i, j).shape))];
    end
    M = [M; mx];
  end

  return;
