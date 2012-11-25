function E = intersection_ea(E1, X)
%
% INTERSECTION_EA - external ellipsoidal approximation of the intersection of
%                   two ellipsoids, or ellipsoid and halfspace, or ellipsoid
%                   and polytope.
%
%
% Description:
% ------------
%
%     E = INTERSECTION_EA(E1, E2) Given two ellipsoidal arrays of equal sizes,
%                                 E1 and E2, or, alternatively, E1 or E2 must be
%                                 a single ellipsoid, computes the ellipsoid 
%                                 that contains the intersection of two
%                                 corresponding ellipsoids from E1 and from E2.
%      E = INTERSECTION_EA(E1, H) Given array of ellipsoids E1 and array of
%                                 hyperplanes H whose sizes match, computes
%                                 the external ellipsoidal
%                                 approximations of intersections of ellipsoids
%                                 and halfspaces defined by hyperplanes in H.
%                                 If v is normal vector of hyperplane and c - shift,
%                                 then this hyperplane defines halfspace
%                                         <v, x> <= c.
%      E = INTERSECTION_EA(E1, P) Given array of ellipsoids E1 and array of
%                                 polytopes P whose sizes match, computes
%                                 the external ellipsoidal approximations
%                                 of intersections of ellipsoids E1 and
%                                 polytopes P.
%
%    The method used to compute the minimal volume overapproximating ellipsoid
%    is described in "Ellipsoidal Calculus Based on Propagation and Fusion"
%    by Lluis Ros, Assumpta Sabater and Federico Thomas;
%    IEEE Transactions on Systems, Man and Cybernetics, Vol.32, No.4, pp.430-442, 2002.
%    For more information, visit
%               http://www-iri.upc.es/people/ros/ellipsoids.html
%
%
% Output:
% -------
%
%    E - array of external approximating ellipsoids;
%        entries can be empty ellipsoids if the corresponding intersection
%        is empty.
%
%
% See also:
% ---------
%
%    ELLIPSOID/ELLIPSOID, INTERSECTION_IA, INTERSECT, DISTANCE,
%    HYPERPLANE/HYPERPLANE, POLYTOPE/POLYTOPE.
%

%
% Author:
% -------
%
%    Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
%


  if ~(isa(E1, 'ellipsoid'))
    error('INTERSECTION_EA: first input argument must be ellipsoid.');
  end
  if ~(isa(X, 'ellipsoid')) && ~(isa(X, 'hyperplane')) && ~(isa(X, 'polytope'))
    error('INTERSECTION_EA: second input argument must be ellipsoid, hyperplane or polytope.');
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

  if (mn1 ~= mx1) || (mn2 ~= mx2) || (mx1 ~= mx2)
    if isa(X, 'hyperplane')
      error('INTERSECTION_EA: ellipsoids and hyperplanes must be of the same dimension.');
    elseif isa(X, 'polytope')
      error('INTERSECTION_EA: ellipsoids and polytopes must be of the same dimension.');
    else
      error('INTERSECTION_EA: ellipsoids must be of the same dimension.');
    end
  end

  t1     = k * l;
  t2     = m * n;
  if (t1 > 1) && (t2 > 1) && ((k ~= m) || (l ~= n))
    if isa(X, 'hyperplane')
      error('INTERSECTION_EA: sizes of ellipsoidal and hyperplane arrays do not match.');
    elseif isa(X, 'polytope')
      error('INTERSECTION_EA: sizes of ellipsoidal and polytope arrays do not match.');
    else
      error('INTERSECTION_EA: sizes of ellipsoidal arrays do not match.');
    end
  end

  E = [];
  if (t1 > 1) && (t2 > 1)
    for i = 1:k
      e = [];
      for j = 1:l
        if isa(X, 'polytope')
          e = [e l_polyintersect(E1, X(j))];
        else
          e = [e l_intersection_ea(E1(i, j), X(i, j))];
        end
      end
      E = [E; e];
    end
  elseif t1 > 0
    for i = 1:k
      e = [];
      for j = 1:l
        if isa(X, 'polytope')
          e = [e l_polyintersect(E1, X)];
        else
          e = [e l_intersection_ea(E1(i, j), X)];
        end
      end
      E = [E; e];
    end
  else
    for i = 1:m
      e = [];
      for j = 1:n
        if isa(X, 'polytope')
          e = [e l_polyintersect(E1, X(j))];
        else
          e = [e l_intersection_ea(E1, X(i, j))];
        end
      end
      E = [E; e];
    end
  end

end





%%%%%%%%

function E = l_intersection_ea(E1, E2)
%
% L_INTERSECTION_EA - computes external ellipsoidal approximation of intersection
%                     of single ellipsoid with single ellipsoid or halfspace.
%

  q1 = E1.center;
  Q1 = E1.shape;
  if rank(Q1) < size(Q1, 1)
    Q1 = ell_inv(ellipsoid.regularize(Q1,E1.absTol));
  else
    Q1 = ell_inv(Q1);
  end

  if isa(E2, 'hyperplane')
    [v, c] = parameters(-E2);
    c      = c/sqrt(v'*v);
    v      = v/sqrt(v'*v);
    if (v'*q1 > c) && ~(intersect(E1, E2))
      E = E1;
      return;
    end
    if (v'*q1 < c) && ~(intersect(E1, E2))
      E = ellipsoid;
      return;
    end
    h  = 2*sqrt(maxeig(E1));
    q2 = c*v + h*v;
    Q2 = (v*v')/(h^2);

    [q, Q] = parameters(hpintersection(E1, E2));
    q2     = q + h*v;
  else
    if E1 == E2
      E = E1;
      return;
    end
    if ~intersect(E1, E2)
      E = ellipsoid;
      return;
    end
    q2 = E2.center;
    Q2 = E2.shape;
    if rank(Q2) < size(Q2, 1)
      Q2 = ell_inv(ellipsoid.regularize(Q2,E2.absTol));
    else
      Q2 = ell_inv(Q2);
    end
  end

  a = l_get_lambda(q1, Q1, q2, Q2, isa(E2, 'hyperplane'));
  X = a*Q1 + (1 - a)*Q2;
  X = 0.5*(X + X');
 % if rank(X) < size(X, 1)
 %   X = ellipsoid.regularize(X);
 % end
  Y = ell_inv(X);
  Y = 0.5*(Y + Y');
  k = 1 - a*(1 - a)*(q2 - q1)'*Q2*Y*Q1*(q2 - q1);
  q = Y*(a*Q1*q1 + (1 - a)*Q2*q2);
  Q = (1+E1.absTol)*k*Y;
  E = ellipsoid(q, Q); 
  
end





%%%%%%%%

function a = l_get_lambda(q1, Q1, q2, Q2, flag)
%
% L_GET_LAMBDA - find parameter value for minimal volume ellipsoid.
%

  [a, f] = fzero(@ell_fusionlambda, 0.5, [], q1, Q1, q2, Q2, size(q1, 1));

  if (a < 0) | (a > 1) 
    if flag | (det(Q1) > det(Q2))
      a = 1;
    else
      a = 0;
    end
  end

end





%%%%%%%%

function EA = l_polyintersect(E, P)
%
% L_POLYINTERSECT - computes external ellipsoidal approximation of intersection
%                   of single ellipsoid with single polytope.
%

  EA = E;
  HA = polytope2hyperplane(P);
  n  = size(HA, 2);

  if isinside(E, P)
    EA = getOutterEllipsoid(P);
    return;
  end

  for i = 1:n
    EA = intersection_ea(EA, HA(i));
  end

end