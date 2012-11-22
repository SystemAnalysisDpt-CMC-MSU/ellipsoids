function IA = minkmp_ia(E1, E2, EE, L)
%
% MINKMP_IA - computation of internal approximating ellipsoids
%             of (E0 - E) + (E1 + ... + En) in given directions.
%
%
% Description:
% ------------
%
% IA = MINKMP_IA(E0, E, EE, L)  Computes internal approximating ellipsoids
%                               of (E0 - E) + (E1 + E2 + ... + En),
%                               where E1, E2, ..., En are ellipsoids in array EE,
%                               in directions specified by columns of matrix L.
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
%    ELLIPSOID/ELLIPSOID, MINKMP, MINKMP_EA, MINKSUM_IA, MINKDIFF_IA, MINKPM_IA.
%

%
% Author:
% -------
%
%    Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
%

  import elltool.conf.Properties;

  if ~(isa(EE, 'ellipsoid')) || ~(isa(E2, 'ellipsoid')) || ~(isa(E1, 'ellipsoid'))
    error('MINKMP_IA: first, second and third arguments must be ellipsoids.');
  end

  [k, l] = size(E1);
  [m, n] = size(E2);
  if (k ~= 1) || (l ~= 1) || (m ~= 1) || (n ~= 1)
    error('MINKMP_IA: first and second arguments must be single ellipsoids.');
  end

  k  = size(L, 1);
  m  = dimension(E1);
  n  = dimension(E2);
  mn = min(min(dimension(EE)));
  mx = max(max(dimension(EE)));
  if (mn ~= mx) || (mn ~= n) || (m ~= n)
    error('MINKMP_IA: all ellipsoids must be of the same dimension.');
  end
  if n ~= k
    error('MINKMP_IA: dimension of the direction vectors must be the same as dimension of ellipsoids.');
  end

  IA = [];

  if ~isbigger(E1, E2)
    if Properties.getIsVerbose()
      fprintf('MINKMP_IA: the resulting set is empty.\n');
    end
    return;
  end

  LL                 = [];
  N                  = size(L, 2);
  [m, n]             = size(EE);
  EE                 = reshape(EE, 1, m*n);
  vrb                = Properties.getIsVerbose();
  Properties.setIsVerbose(false);


  for i = 1:N
    l = L(:, i);
    if ~isbaddirection(E1, E2, l)
      LL = [LL l];
      IA = [IA minksum_ia([minkdiff_ia(E1, E2, l) EE], l)];
    end
  end
  
  Properties.setIsVerbose(vrb);
  if isempty(IA)
    if Properties.getIsVerbose()
      fprintf('MINKMP_IA: cannot compute external approximation for any\n');
      fprintf('           of the specified directions.\n');
    end
  end

end
