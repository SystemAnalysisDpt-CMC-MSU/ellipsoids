function EA = minkpm_ea(EE, E2, L)
%
% MINKPM_EA - computation of external approximating ellipsoids
%             of (E1 + E2 + ... + En) - E in given directions.
%
%
% Description:
% ------------
%
%    EA = MINKPM_EA(EE, E, L)  Computes external approximating ellipsoids
%                              of (E1 + E2 + ... + En) - E,
%                              where E1, E2, ..., En are ellipsoids in array EE,
%                              in directions specified by columns of matrix L.
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
%    ELLIPSOID/ELLIPSOID, MINKPM, MINKPM_IA, MINKSUM_EA, MINKDIFF_EA, MINKMP_EA.
%

%
% Author:
% -------
%
%    Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
%

  import elltool.conf.Properties;


  if ~(isa(EE, 'ellipsoid')) | ~(isa(E2, 'ellipsoid'))
    error('MINKPM_EA: first and second arguments must be ellipsoids.');
  end

  [m, n] = size(E2);
  if (m ~= 1) | (n ~= 1)
    error('MINKPM_EA: second argument must be single ellipsoid.');
  end

  k  = size(L, 1);
  n  = dimension(E2);
  mn = min(min(dimension(EE)));
  mx = max(max(dimension(EE)));
  if (mn ~= mx) | (mn ~= n)
    error('MINKPM_EA: all ellipsoids must be of the same dimension.');
  end
  if n ~= k
    error('MINKPM_EA: dimension of the direction vectors must be the same as dimension of ellipsoids.');
  end

  N                  = size(L, 2);
  EA                 = [];
  vrb                = Properties.getIsVerbose();
  Properties.setIsVerbose(false);
  
  % sanity check: the approximated set should be nonempty
  for i = 1:N
    [U, S, V] = svd(L(:, i));
    ET        = minksum_ea(EE, U);
    if min(ET > E2) < 1
      if vrb > 0
        fprintf('MINKPM_EA: the resulting set is empty.\n');
      end       
      Properties.setIsVerbose(vrb);
      return;
    end
  end

  ES = minksum_ea(EE, L);

  for i = 1:N
    E = ES(i);
    l = L(:, i);
    if ~isbaddirection(E, E2, l)
      EA = [EA minkdiff_ea(E, E2, l)];
    end
  end
  
  Properties.setIsVerbose(vrb);

  if isempty(EA)
    if Properties.getIsVerbose()
      fprintf('MINKPM_EA: cannot compute external approximation for any\n');
      fprintf('           of the specified directions.\n');
    end
  end

  return;
