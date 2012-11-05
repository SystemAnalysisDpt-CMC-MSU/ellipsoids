function E = intersection_ia(E1, X)
%
% INTERSECTION_IA - internal ellipsoidal approximation of the intersection of
%                   of ellipsoid and ellipsoid, or ellipsoid and halfspace,
%                   or ellipsoid and polytope.
%
%
% Description:
% ------------
%
%  E = INTERSECTION_IA(E1, E2) Given two ellipsoidal arrays of equal sizes,
%                              E1 and E2, or, alternatively, E1 or E2 must be
%                              a single ellipsoid, comuptes the internal
%                              ellipsoidal approximations of intersections of
%                              two corresponding ellipsoids from E1 and from E2.
%   E = INTERSECTION_IA(E1, H) Given array of ellipsoids E1 and array of
%                              hyperplanes H whose sizes match, computes
%                              the internal ellipsoidal approximations of
%                              intersections of ellipsoids and halfspaces
%                              defined by hyperplanes in H.
%                              If v is normal vector of hyperplane and c - shift,
%                              then this hyperplane defines halfspace
%                                         <v, x> <= c.
%   E = INTERSECTION_IA(E1, P) Given array of ellipsoids E1 and array of
%                              polytopes P whose sizes match, computes
%                              the internal ellipsoidal approximations of
%                              intersections of ellipsoids E1 and polytopes P.
%
%
% Output:
% -------
%
%    E - array of internal approximating ellipsoids;
%        entries can be empty ellipsoids if the corresponding intersection
%        is empty.
%
%
% See also:
% ---------
%
%    ELLIPSOID/ELLIPSOID, INTERSECTION_EA, INTERSECT, DISTANCE,
%    HYPERPLANE/HYPERPLANE, POLYTOPE/POLYTOPE.
%

%
% Author:
% -------
%
%    Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
%

  import elltool.conf.Properties;


  if ~(isa(E1, 'ellipsoid'))
    error('INTERSECTION_IA: first input argument must be ellipsoid.');
  end
  if ~(isa(X, 'ellipsoid')) & ~(isa(X, 'hyperplane')) & ~(isa(X, 'polytope'))
    error('INTERSECTION_IA: second input argument must be ellipsoid, hyperplane or polytope.');
  end

  [k, l] = size(E1);
  [m, n] = size(X);
  dims1  = dimension(E1);

  if isa(X, 'polytope')
    dims2 = [];
    for i = 1:m
      dd = [];
      for j = 1:n
        dd = [dd dimension(X(j))];
      end
      dims2 = [dims2; dd];
    end
  else
    dims2 = dimension(X);
  end

  mn1   = min(min(dims1));
  mn2   = min(min(dims2));
  mx1   = max(max(dims1));
  mx2   = max(max(dims2));
  if (mn1 ~= mx1) | (mn2 ~= mx2) | (mx1 ~= mx2)
    if isa(X, 'hyperplane')
      error('INTERSECTION_IA: ellipsoids and hyperplanes must be of the same dimension.');
    elseif isa(X, 'polytope')
      error('INTERSECTION_IA: ellipsoids and polytopes must be of the same dimension.');
    else
      error('INTERSECTION_IA: ellipsoids must be of the same dimension.');
    end
  end

  t1     = k * l;
  t2     = m * n;
  if (t1 > 1) & (t2 > 1) & ((k ~= m) | (l ~= n))
    if isa(X, 'hyperplane')
      error('INTERSECTION_IA: sizes of ellipsoidal and hyperplane arrays do not match.');
    elseif isa(X, 'polytope')
      error('INTERSECTION_IA: sizes of ellipsoidal and polytope arrays do not match.');
    else
      error('INTERSECTION_IA: sizes of ellipsoidal arrays do not match.');
    end
  end

  E = [];
  if (t1 > 1) & (t2 > 1)
    for i = 1:k
      e = [];
      for j = 1:l
        if isa(X, 'polytope')
          e = [e l_polyintersect(E1(i, j), X(j))];
        else
          e = [e l_intersection_ia(E1(i, j), X(i, j))];
        end
      end
      E = [E; e];
    end
  elseif t1 > 0
    for i = 1:k
      e = [];
      for j = 1:l
        if isa(X, 'polytope')
          e = [e l_polyintersect(E1(i, j), X)];
        else
          e = [e l_intersection_ia(E1(i, j), X)];
        end
      end
      E = [E; e];
    end
  else
    for i = 1:m
      e = [];
      for j = 1:n
        if isa(X, 'polytope')
          e = [e l_polyintersect(E1(i, j), X(j))];
        else
          e = [e l_intersection_ia(E1, X(i, j))];
        end
      end
      E = [E; e];
    end
  end

  return;





%%%%%%%%

function E = l_intersection_ia(E1, E2)
%
% L_INTERSECTION_IA - computes internal ellipsoidal approximation of intersection
%                     of single ellipsoid with single ellipsoid or halfspace.
%

  import elltool.conf.Properties;

  if isa(E2, 'ellipsoid')
    if E1 == E2
      E = E1;
    elseif ~intersect(E1, E2)
      E = ellipsoid;
    else
      E = ellintersection_ia([E1 E2]);
    end
    return;
  end

  q1 = E1.center;
  Q1 = E1.shape;
  if rank(Q1) < size(Q1, 1)
    Q1 = ell_inv(regularize(Q1));
  else
    Q1 = ell_inv(Q1);
  end

  [v, c] = parameters(-E2);
  c      = c/sqrt(v'*v);
  v      = v/sqrt(v'*v);
  if (v'*q1 > c) & ~(intersect(E1, E2))
    E = E1;
    return;
  end
  if (v'*q1 < c) & ~(intersect(E1, E2))
    E = ellipsoid;
    return;
  end

  [q, Q] = parameters(hpintersection(E1, E2));
  [r, x] = rho(E1, v);
  h      = 2*sqrt(maxeig(E1));
  q2     = q + h*v;
  Q2     = (v*v')/(h^2);
  st1    = 0;
  st2    = 0;
  e1     = (q1 - q)'*Q1*(q1 - q);
  e2     = (q2 - x)'*Q2*(q2 - x);
  a1     = (1 - e2)/(1 - e1*e2);
  a2     = (1 - e1)/(1 - e1*e2);
  Q      = a1*Q1 + a2*Q2;
  Q      = 0.5*(Q + Q');
  q      = ell_inv(Q)*(a1*Q1*q1 + a2*Q2*q2);
  Q      = Q/(1 - (a1*q1'*Q1*q1 + a2*q2'*Q2*q2 - q'*Q*q));
  Q      = ell_inv(Q);
  Q      = (1-Properties.getAbsTol())*0.5*(Q + Q');
  E      = ellipsoid(q, Q);
  
  return;

  



%%%%%%%%

function EA = l_polyintersect(E, P)
%
% L_POLYINTERSECT - computes internal ellipsoidal approximation of intersection
%                   of single ellipsoid with single polytope.
%

  import elltool.conf.Properties;

  EA = E;
  HA = polytope2hyperplane(P);
  n  = size(HA, 2);

  for i = 1:n
    EA = intersection_ia(EA, HA(i));
  end

  if isinside(E, P)
    EA = getInnerEllipsoid(P);
    return;
  end

  return;
