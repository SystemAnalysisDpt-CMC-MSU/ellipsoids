function res = isbigger(E1, E2)
%
% ISBIGGER - checks if one ellipsoid would contain the other if their centers
%            would coincide.
%
%
% Description:
% ------------
%
%    RES = ISBIGGER(E1, E2)  Given two single ellipsoids of the same dimension,
%                            E1 and E2, check if E1 would contain E2 inside if
%                            they were both centered at origin.
%
%
% Output:
% -------
%
%    1 - if ellipsoid E1 would contain E2 inside, 0 - otherwise.
%
%
% See also:
% ---------
%
%    ELLIPSOID/ELLIPSOID.
%

%
% Author:
% -------
%
%    Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
%

  import elltool.conf.Properties;


  if ~(isa(E1, 'ellipsoid')) | ~(isa(E2, 'ellipsoid'))
    error('ISBIGGER: both arguments must be single ellipsoids.');
  end

  [k, l] = size(E1);
  [m, n] = size(E2);
  if (k > 1) | (l > 1) | (m > 1) | (n > 1)
    error('ISBIGGER: both arguments must be single ellipsoids.');
  end

  [m, r1] = dimension(E1);
  [n, r2] = dimension(E2);
  if m ~= n
    error('ISBIGGER: both ellipsoids must be of the same dimension.');
  end
  if r1 < r2
    res = 0;
    return;
  end

  A = E1.shape;
  B = E2.shape;
  if r1 < m
    if Properties.getIsVerbose()
      fprintf('ISBIGGER: Warning! First ellipsoid is degenerate.');
      fprintf('          Regularizing...');
    end
    A = regularize(A);
  end

  T = ell_simdiag(A, B);
  if max(abs(diag(T*B*T'))) < (1 + Properties.getAbsTol())
    res = 1;
  else
    res = 0;
  end

  return;
