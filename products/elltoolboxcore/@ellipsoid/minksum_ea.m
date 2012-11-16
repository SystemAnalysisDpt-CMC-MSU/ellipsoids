function EA = minksum_ea(E, L)
%
% MINKSUM_EA - computation of external approximating ellipsoids of the geometric
%              sum of ellipsoids in given directions.
%
%
% Description:
% ------------
%
%    EA = MINKSUM_EA(E, L)  Computes tight external approximating ellipsoids
%                           for the geometric sum of the ellipsoids in the array E
%                           in directions specified by columns of L.
%                           If ellipsoids in E are n-dimensional, matrix L
%                           must have dimension (n x k) where k can be arbitrarily
%                           chosen. In this case, the output of the function
%                           will contain k ellipsoids computed for k directions
%                           specified in L.
%
%    Let E(q1, Q1), E(q2, Q2), ..., E(qm, Qm) be ellipsoids in R^n,
%    and l - some vector in R^n. Then tight external approximating ellipsoid E(q, Q)
%    for the geometric sum E(q1, Q1) + E(q2, Q2) + ... + E(qm, Qm) in direction l,
%    is such that
%                 rho(l | E(q, Q)) = rho(l | (E(q1, Q1) + ... + E(qm, Qm)))
%    and is defined as follows:
%                      q = q1 + q2 + ... + qm,
%                      Q = (p1 + ... + pm)((1/p1)Q1 + ... + (1/pm)Qm),
%    where
%          p1 = sqrt(<l, Q1l>), ..., pm = sqrt(<l, Qml>).
%
%
% Output:
% -------
%
%    EA - array external approximating ellipsoids.
%
%
% See also:
% ---------
%
%    ELLIPSOID/ELLIPSOID, MINKSUM, MINKSUM_IA, MINKDIFF, MINKDIFF_EA, MINKDIFF_IA.
%

%
% Author:
% -------
%
%    Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
%

  import elltool.conf.Properties;


  if ~(isa(E, 'ellipsoid'))
    error('MINKSUM_EA: first argument must be array of ellipsoids.');
  end

  dims = dimension(E);
  m    = min(min(dims));
  n    = max(max(dims));
  if m ~= n
    error('MINKSUM_EA: ellipsoids in the array must be of the same dimension.');
  end

  [k, d] = size(L);
  if (k ~= n)
    msg = sprintf('MINKSUM_EA: second argument must be vector(s) in R^%d.', n);
    error(msg);
  end

  [m, n] = size(E);
  if (m == 1) & (n == 1)
    EA = E;
    return;
  end

  EA = [];
  absTolMat = getAbsTol(E);
  for ii = 1:d
    l = L(:, ii);
    for i = 1:m
      for j = 1:n
        Q = E(i, j).shape;
        if size(Q, 1) > rank(Q)
          if Properties.getIsVerbose()
            fprintf('MINKSUM_EA: Warning! Degenerate ellipsoid.\n');
            fprintf('            Regularizing...\n');
          end
          Q = regularize(Q,absTolMat(i,j));
        end
  
        p = sqrt(l'*Q*l);

        if (i == 1) & (j == 1)
          q = E(i, j).center;
          S = (1/p) * Q;
          P = p;
        else
          q = q + E(i, j).center;
          S = S + ((1/p) * Q);
          P = P + p;
        end
      end
    end
    S  = 0.5*P*(S + S');
    EA = [EA ellipsoid(q, S)];
  end

  return;
