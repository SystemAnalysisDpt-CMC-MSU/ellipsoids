function IA = minkdiff_ia(E1, E2, L)
%
% MINKDIFF_IA - computation of internal approximating ellipsoids of the geometric
%               difference of two ellipsoids in given directions.
%
%
% Description:
% ------------
%
%    IA = MINKDIFF_IA(E1, E2, L)  Computes internal approximating ellipsoids
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
%    If these two conditions are satisfied, then internal approximating
%    ellipsoid for the geometric difference E1 - E2 in the direction l
%    is defined by its shape matrix
%                 Q = (1 - (1/P)) Q1 + (1 - P) Q2
%    and its center
%                 q = q1 - q2,
%    where q1 is center of E1 and q2 - center of E2.
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
%    ELLIPSOID/ELLIPSOID, MINKDIFF_EA, MINKDIFF, ISBIGGER, ISBADDIRECTION,
%                         MINKSUM_EA, MINKSUM_IA.
%

%
% Author:
% -------
%
%    Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
%
  import modgen.common.throwerror;
  import elltool.conf.Properties;


  if ~(isa(E1, 'ellipsoid')) | ~(isa(E2, 'ellipsoid'))
    throwerror('wrongInput', 'MINKDIFF_IA: first and second arguments must be single ellipsoids.');
  end

  [k, l] = size(E1);
  [m, n] = size(E2);
  if (k ~= 1) | (l ~= 1) | (m ~= 1) | (n ~= 1)
    throwerror('wrongInput', 'MINKDIFF_IA: first and second arguments must be single ellipsoids.');
  end

  IA = [];

  if isbigger(E1, E2) == 0
    if Properties.getIsVerbose()
      fprintf('MINKDIFF_IA: geometric difference of these two ellipsoids is empty set.\n');
    end
    return;
  end

  k = size(L, 1);
  n = dimension(E1);
  if k ~= n
    throwerror('wrongSizes', 'MINKDIFF_IA: dimension of the direction vectors must be the same as dimension of ellipsoids.');
  end
  q  = E1.center - E2.center;
  Q1 = E1.shape;
  if rank(Q1) < size(Q1, 1)
    Q1 = ellipsoid.regularize(Q1,E1.absTol);
  end
  Q2 = E2.shape;
  if rank(Q2) < size(Q2, 1)
    Q2 = ellipsoid.regularize(Q2,E2.absTol);
  end
  L  = ellipsoid.rm_bad_directions(Q1, Q2, L);
  m  = size(L, 2);
  if m < 1
    if Properties.getIsVerbose()
      fprintf('MINKDIFF_IA: cannot compute internal approximation for any\n');
      fprintf('             of the specified directions.\n');
    end
    return;
  end
  for i = 1:m
    l  = L(:, i);
    p  = (sqrt(l'*Q1*l))/(sqrt(l'*Q2*l));
    Q  = (1 - (1/p))*Q1 + (1 - p)*Q2;
    IA = [IA ellipsoid(q, Q)];
  end 

  return;
