function res = isbaddirection(E1, E2, L)
%
% ISBADDIRECTION - checks if ellipsoidal approximations of geometric difference
%                  of two ellipsoids can be computed for given directions.
%
%
% Description:
% ------------
%
%    RES = ISBADDIRECTION(E1, E2, L)  Checks if it is possible to build ellipsoidal
%                                     approximation of the geometric difference
%                                     of two ellipsoids E1 - E2 in directions
%                                     specified by matrix L (columns of L are
%                                     direction vectors).
%
%    Type 'help minkdiff_ea' or 'help minkdiff_ia' for more information.
%
%
% Output:
% -------
%
%    RES - array of 1 or 0 with length being equal to the number of columns
%          in matrix L.
%          1 marks direction vector as bad - ellipsoidal approximation cannot
%          be computed for this direction.
%          0 means the opposite.
%
%
% See also:
% ---------
%
%    ELLIPSOID/ELLIPSOID, MINKDIFF, MINKDIFF_EA, MINKDIFF_IA.
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

  [k, d] = size(L);

  if isbigger(E1, E2) == 0
    if ellOptions.verbose > 0
      fprintf('ISBADDIRECTION: geometric difference of these two ellipsoids is empty set.\n');
      fprintf('                All directions are bad.\n');
    end
    res = ones(1, d);
    return;
  end

  n = dimension(E1);

  if k ~= n
    error('ISBADDIRECTION: direction vectors must be of the same dimension as ellipsoids.');
  end

  res = [];
  Q1  = E1.shape;
  Q2  = E2.shape;
  T   = ell_simdiag(Q2, Q1);
  a   = min(abs(diag(T*(Q1)*T')));
  for i = 1:d
    l = L(:, i);
    p = sqrt(l'*Q1*l)/sqrt(l'*Q2*l);
    if a > p
      res = [res 0];
    else
      res = [res 1];
    end
  end

  return;
