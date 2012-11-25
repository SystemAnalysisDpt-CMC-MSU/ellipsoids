function IA = minksum_ia(E, L)
%
% MINKSUM_IA - computation of internal approximating ellipsoids of the geometric
%              sum of ellipsoids in given directions.
%
%
% Description:
% ------------
%
%    IA = MINKSUM_IA(E, L)  Computes tight internal approximating ellipsoids
%                           for the geometric sum of the ellipsoids in the array E
%                           in directions specified by columns of L.
%                           If ellipsoids in E are n-dimensional, matrix L
%                           must have dimension (n x k) where k can be arbitrarily
%                           chosen. In this case, the output of the function
%                           will contain k ellipsoids computed for k directions
%                           specified in L.
%
%    Let E(q1, Q1), E(q2, Q2), ..., E(qm, Qm) be ellipsoids in R^n,
%    and l - some vector in R^n. Then tight internal approximating ellipsoid E(q, Q)
%    for the geometric sum E(q1, Q1) + E(q2, Q2) + ... + E(qm, Qm) in direction l,
%    is such that
%                 rho(l | E(q, Q)) = rho(l | (E(q1, Q1) + ... + E(qm, Qm)))
%    and is defined as follows:
%     q = q1 + q2 + ... + qm,
%     Q = (S1 Q1^(1/2) + ... + Sm Qm^(1/2))' (S1 Q1^(1/2) + ... + Sm Qm^(1/2)),
%    where S1 = I (identity), and S2, ..., Sm are orthogonal matrices such that
%    vectors (S1 Q1^(1/2) l), ..., (Sm Qm^(1/2) l) are parallel.
%
%
% Output:
% -------
%
%    IA - array internal approximating ellipsoids.
%
%
% See also:
% ---------
%
%    ELLIPSOID/ELLIPSOID, MINKSUM, MINKSUM_EA, MINKDIFF, MINKDIFF_EA, MINKDIFF_IA.
%

%
% Author:
% -------
%
%    Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
%

  import elltool.conf.Properties;


  if ~(isa(E, 'ellipsoid'))
    error('MINKSUM_IA: first argument must be array of ellipsoids.');
  end

  dims = dimension(E);
  m    = min(min(dims));
  n    = max(max(dims));
  if m ~= n
    error('MINKSUM_IA: ellipsoids in the array must be of the same dimension.');
  end

  [k, d] = size(L);
  if (k ~= n)
    msg = sprintf('MINKSUM_IA: second argument must be vector(s) in R^%d.', n);
    error(msg);
  end

  [m, n] = size(E);
  if (m == 1) && (n == 1)
    IA = E;
    return;
  end

  IA = [];  
  absTolMat = getAbsTol(E);
  for ii = 1:d
    l = L(:, ii);
    for i = 1:m
      for j = 1:n
        Q = E(i, j).shape;
        if size(Q, 1) > rank(Q)
          if Properties.getIsVerbose()
            fprintf('MINKSUM_IA: Warning! Degenerate ellipsoid.\n');
            fprintf('            Regularizing...\n');
          end
          Q = ellipsoid.regularize(Q,absTolMat(i,j));
        end
        Q = sqrtm(Q);
        if (i == 1) && (j == 1)
          q = E(i, j).center;
          v = Q * l;
          M = Q;
        else
          q = q + E(i, j).center;
          T = ell_valign(v, Q*l);
          M = M + T*Q;
        end
      end
    end
    IA = [IA ellipsoid(q, M'*M)];
  end

end
