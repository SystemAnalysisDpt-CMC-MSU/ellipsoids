function EA = minkmp_ea(E1, E2, EE, L)
%
% MINKMP_EA - computation of external approximating ellipsoids
%             of (E0 - E) + (E1 + ... + En) in given directions.
%
%
% Description:
% ------------
%
% EA = MINKMP_EA(E0, E, EE, L)  Computes external approximating ellipsoids
%                               of (E0 - E) + (E1 + E2 + ... + En),
%                               where E1, E2, ..., En are ellipsoids in array EE,
%                               in directions specified by columns of matrix L.
%
%
% Output:
% -------
%
%    EA - array of external approximating ellipsoids
%         (empty, if for all specified directions approximations cannot be computed).
%
%
% See also:
% ---------
%
%    ELLIPSOID/ELLIPSOID, MINKMP, MINKMP_IA, MINKSUM_EA, MINKDIFF_EA, MINKPM_EA.
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

  if ~(isa(EE, 'ellipsoid')) | ~(isa(E2, 'ellipsoid')) | ~(isa(E1, 'ellipsoid'))
    error('MINKMP_EA: first, second and third arguments must be ellipsoids.');
  end

  [k, l] = size(E1);
  [m, n] = size(E2);
  if (k ~= 1) | (l ~= 1) | (m ~= 1) | (n ~= 1)
    error('MINKMP_EA: first and second arguments must be single ellipsoids.');
  end

  k  = size(L, 1);
  m  = dimension(E1);
  n  = dimension(E2);
  mn = min(min(dimension(EE)));
  mx = max(max(dimension(EE)));
  if (mn ~= mx) | (mn ~= n) | (m ~= n)
    error('MINKMP_EA: all ellipsoids must be of the same dimension.');
  end
  if n ~= k
    error('MINKMP_EA: dimension of the direction vectors must be the same as dimension of ellipsoids.');
  end

  EA = [];

  if ~isbigger(E1, E2)
    if ellOptions.verbose > 0
      fprintf('MINKMP_EA: the resulting set is empty.\n');
    end
    return;
  end

  LL                 = [];
  N                  = size(L, 2);
  [m, n]             = size(EE);
  EE                 = reshape(EE, 1, m*n);
  vrb                = ellOptions.verbose;
  ellOptions.verbose = 0;

  for i = 1:N
    l = L(:, i);
    if ~isbaddirection(E1, E2, l)
      LL = [LL l];
      EA = [EA minksum_ea([minkdiff_ea(E1, E2, l) EE], l)];
    end
  end

  ellOptions.verbose = vrb;

  if isempty(EA)
    if ellOptions.verbose > 0
      fprintf('MINKMP_EA: cannot compute external approximation for any\n');
      fprintf('           of the specified directions.\n');
    end
  end

  return;
