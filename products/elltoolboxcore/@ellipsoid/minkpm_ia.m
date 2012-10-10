function IA = minkpm_ea(EE, E2, L)
%
% MINKPM_IA - computation of internal approximating ellipsoids
%             of (E1 + E2 + ... + En) - E in given directions.
%
%
% Description:
% ------------
%
%    IA = MINKPM_IA(EE, E, L)  Computes internal approximating ellipsoids
%                              of (E1 + E2 + ... + En) - E,
%                              where E1, E2, ..., En are ellipsoids in array EE,
%                              in directions specified by columns of matrix L.
%
%
% Output:
% -------
%
%    IA - array of internal approximating ellipsoids
%         (empty, if for all specified directions approximations cannot be computed).
%
%
% See also:
% ---------
%
%    ELLIPSOID/ELLIPSOID, MINKPM, MINKPM_EA, MINKSUM_IA, MINKDIFF_IA, MINKMP_IA.
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

  if ~(isa(EE, 'ellipsoid')) | ~(isa(E2, 'ellipsoid'))
    error('MINKPM_IA: first and second arguments must be ellipsoids.');
  end

  [m, n] = size(E2);
  if (m ~= 1) | (n ~= 1)
    error('MINKPM_IA: second argument must be single ellipsoid.');
  end

  k  = size(L, 1);
  n  = dimension(E2);
  mn = min(min(dimension(EE)));
  mx = max(max(dimension(EE)));
  if (mn ~= mx) | (mn ~= n)
    error('MINKPM_IA: all ellipsoids must be of the same dimension.');
  end
  if n ~= k
    error('MINKPM_IA: dimension of the direction vectors must be the same as dimension of ellipsoids.');
  end

  N                  = size(L, 2);
  IA                 = [];
  ES                 = minksum_ia(EE, L);
  vrb                = ellOptions.verbose;
  ellOptions.verbose = 0;

  for i = 1:N
    E = ES(i);
    l = L(:, i);
    if isbigger(E, E2)
      if ~isbaddirection(E, E2, l)
        IA = [IA minkdiff_ia(E, E2, l)];
      end
    end
  end

  ellOptions.verbose = vrb;

  if isempty(IA)
    if ellOptions.verbose > 0
      fprintf('MINKPM_IA: cannot compute internal approximation for any\n');
      fprintf('           of the specified directions.\n');
    end
  end

  return;
