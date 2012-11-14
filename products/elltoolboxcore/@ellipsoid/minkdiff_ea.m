function EA = minkdiff_ea(E1, E2, L)
%
% MINKDIFF_EA - computation of external approximating ellipsoids of the geometric
%               difference of two ellipsoids in given directions.
%
%
% Description:
% ------------
%
%    EA = MINKDIFF_EA(E1, E2, L)  Computes external approximating ellipsoids
%                                 of the geometric difference of two ellipsoids E1 - E2
%                                 in directions specified by columns of matrix L.
%
%    First condition for the approximations to be computed, is that ellipsoid
%    E1 must be bigger than ellipsoid E2 in the sense that if they had the same
%    center, E2 would be contained inside E1. Otherwise, the geometric difference
%    E1 - E2 is an empty set.
%    Second condition for the approximation in the given direction l to exist,
%    is the following. Given 
%                   P = sqrt(<l, Q1 l>)/sqrt(<l, Q2 l>)
%    where Q1 is the shape matrix of ellipsoid E1, and Q2 - shape matrix of E2,
%    and R being minimal root of the equation
%                   det(Q1 - R Q2) = 0,
%    parameter P should be less than R.
%    If both of these conditions are satisfied, then external approximating
%    ellipsoid is defined by its shape matrix
%             Q = (Q1^(1/2) + S Q2^(1/2))' (Q1^(1/2) + S Q2^(1/2)),
%    where S is orthogonal matrix such that vectors Q1^(1/2) l and S Q2^(1/2) l
%    are parallel, and its center
%             q = q1 - q2,
%    where q1 is center of ellipsoid E1 and q2 - center of E2.
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
%    ELLIPSOID/ELLIPSOID, MINKDIFF_IA, MINKDIFF, ISBIGGER, ISBADDIRECTION,
%                         MINKSUM_EA, MINKSUM_IA.
%

%
% Author:
% -------
%
%    Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
%

  import elltool.conf.Properties;

  if ~(isa(E1, 'ellipsoid')) | ~(isa(E2, 'ellipsoid'))
    error('MINKDIFF_EA: first and second arguments must be single ellipsoids.');
  end

  [k, l] = size(E1);
  [m, n] = size(E2);
  if (k ~= 1) | (l ~= 1) | (m ~= 1) | (n ~= 1)
    error('MINKDIFF_EA: first and second arguments must be single ellipsoids.');
  end

  EA = [];

  if isbigger(E1, E2) == 0
    if Properties.getIsVerbose()
      fprintf('MINKDIFF_EA: geometric difference of these two ellipsoids is empty set.\n');
    end
    return;
  end

  k = size(L, 1);
  n = dimension(E1);
  if k ~= n
    error('MINKDIFF_EA: dimension of the direction vectors must be the same as dimension of ellipsoids.');
  end
  q  = E1.center - E2.center;
  Q1 = E1.shape;
  Q2 = E2.shape;
  L  = rm_bad_directions(Q1, Q2, L);
  m  = size(L, 2);
  if m < 1
    if Properties.getIsVerbose()
      fprintf('MINKDIFF_EA: cannot compute external approximation for any\n');
      fprintf('             of the specified directions.\n');
    end
    return;
  end
  if rank(Q1) < size(Q1, 1)
    Q1 = regularize(Q1,E1.properties.absTol);
  end
  if rank(Q2) < size(Q2, 1)
    Q2 = regularize(Q2,E2.properties.absTol);
  end

  Q1 = sqrtm(Q1);
  Q2 = sqrtm(Q2);

  for i = 1:m
    l  = L(:, i);
    T  = ell_valign(Q1*l, Q2*l);
    Q  = Q1 - T*Q2;
    EA = [EA ellipsoid(q, Q'*Q)];
  end 

  return;
