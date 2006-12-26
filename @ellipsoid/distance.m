function [d, status] = distance(E, X, flag)
%
% DISTANCE - computes distance from the given ellipsoid to the specified object:
%            vector, ellipsoid, hyperplane or polytope.
%
%
% Description:
% ------------
%
%      D = DISTANCE(E, Y)  Given array of ellipsoids E and array of vectors defined
%                          by matrix Y (vectors are columns of Y), so that number
%                          of ellipsoids in E is the same as number of vectors in Y,
%                          or, alternatively, E being single ellipsoid or Y being
%                          single vector, compute the distance from ellipsoids in E
%                          to vectors in Y.
%    D = DISTANCE(E1, E2)  Given two ellipsoidal arrays of the same size, E1 and E2,
%                          or, alternatively, E1 or E2 being single ellipsoid,
%                          compute the distance pairwise.
%      D = DISTANCE(E, H)  Given array of ellipsoids E, and array of hyperplanes H
%                          of the same size, or, alternatively, E being single
%                          ellipsoid or H - single hyperplane structure, 
%                          compute the distance from ellipsoids to hyperplanes pairwise.
%      D = DISTANCE(E, P)  Given array of ellipsoids E, and array of polytopes P
%                          of the same size, or, alternatively, E being single
%                          ellipsoid or P - single polytope object, 
%                          compute the distance from ellipsoids to polytopes pairwise.
%                          Requires Multi-Parametric Toolbox.
%    D = DISTANCE(E, X, F) Optional parameter F, if set to 1, indicates that
%                          the distance should be computed in the metric
%                          of ellipsoids in E. By default (F = 0), the distance
%                          is computed in Euclidean metric.
%
%    Negative distance value means
%      for ellipsoid and vector: vector belongs to the ellipsoid,
%      for two ellipsoids: they intersect,
%      for ellipsoid and hyperplane: ellipsoid intersects the hyperplane.
%    Zero distance value means
%      for ellipsoid and vector: vector is a boundary point of the ellipsoid,
%      for two ellipsoids: they touch,
%      for ellipsoid and hyperplane: ellipsoid touches the hyperplane.
%
%    Distance between ellipsoid E and polytope P is the optimal value
%    of the following problem:
%                               min |x - y|
%                  subject to:  x belongs to E, y belongs to P.
%    Zero distance means that intersection of E and P is nonempty.
%
%
% Output:
% -------
%
%    D - array of distances. 
%    S - (optional) status variable returned by YALMIP.
%
%
% See also:
% ---------
%
%    ELLIPSOID/ELLIPSOID, ISINSIDE, ISINTERNAL, INTERSECT,
%    HYPERPLANE/HYPERPLANE,
%    POLYTOPE/POLYTOPE.
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

  if nargin < 3
    flag = 0;
  end

  if ~(isa(E, 'ellipsoid'))
    error('DISTANCE: first argument must be ellipsoid or array of ellipsoids.');
  end


  if isa(X, 'double')
    [d, status] = l_pointdist(E, X, flag);
    if nargout < 2
      clear status;
    end
    return;
  end

  if isa(X, 'ellipsoid')
    [d, status] = l_elldist(E, X, flag);
    if nargout < 2
      clear status;
    end
    return;
  end

  if isa(X, 'hyperplane')
    [d, status] = l_hpdist(E, X, flag);
    if nargout < 2
      clear status;
    end
    return;
  end
  
  if isa(X, 'polytope')
    [d, status] = l_polydist(E, X);
    if nargout < 2
      clear status;
    end
    return;
  end

  error('DISTANCE: second argument must be array of vectors, ellipsoids, hyperplanes or polytopes.');

  return;




%%%%%%%%
  
function [d, status] = l_pointdist(E, X, flag)
%
% L_POINTDIST - distance from ellipsoid to vector.
%

  global ellOptions;

  [m, n] = size(E);
  [k, l] = size(X);
  t      = m * n;
  if (t > 1) & (l > 1) & (t ~= l)
    error('DISTANCE: number of ellipsoids does not match the number of vectors.');
  end

  dims = dimension(E);
  mn   = min(min(dims));
  mx   = max(max(dims));
  if mn ~= mx
    error('DISTANCE: ellipsoids must be of the same dimension.')
  end
  if mx ~= k
    error('DISTANCE: dimensions of ellipsoid an vector do not match.');
  end

  if ellOptions.verbose > 0
    if (t > 1) | (l > 1)
      fprintf('Computing %d ellipsoid-to-vector distances...\n', max([t l]));
    else
      fprintf('Computing ellipsoid-to-vector distance...\n');
    end
  end

  o.fungrad = 1;
  o.congrad = 1;
  %x0        = [1; zeros(k-1, 1)];
  x0        = rand(k, 1);
  x0        = x0/sqrt(x0'*x0);
  d         = [];
  if (t > 1) & (t == l)
    for i = 1:m
      dd = [];
      for j = 1:n
        y = X(:, i*j);
        switch ellOptions.nlcp_solver
          case 1, % use Optimization Toolbox routines
            o       = optimset('GradObj', 'on', 'GradConstr', 'on');
            if flag
              [x, fv] = fmincon(@distpobjfun, x0, [], [], [], [], [], [], @ellconstraint, o, E(i, j), y, E(i, j).shape); 
            else
              [x, fv] = fmincon(@distpobjfun, x0, [], [], [], [], [], [], @ellconstraint, o, E(i, j), y); 
            end
          otherwise,
            if flag
              [x, fv] = ell_nlfnlc(@distpobjfun, x0, @ellconstraint, o, E(i, j), y, E(i, j).shape); 
            else
              [x, fv] = ell_nlfnlc(@distpobjfun, x0, @ellconstraint, o, E(i, j), y); 
            end
        end
        dd = [dd -fv];
      end
      d = [d; dd];
    end
  elseif (t > 1)
    for i = 1:m
      dd = [];
      for j = 1:n
        switch ellOptions.nlcp_solver
          case 1, % use Optimization Toolbox routines
            o       = optimset('GradObj', 'on', 'GradConstr', 'on');
            if flag
              [x, fv] = fmincon(@distpobjfun, x0, [], [], [], [], [], [], @ellconstraint, o, E(i, j), X, E(i, j).shape); 
            else
              [x, fv] = fmincon(@distpobjfun, x0, [], [], [], [], [], [], @ellconstraint, o, E(i, j), X); 
            end
          otherwise,
            if flag
              [x, fv] = ell_nlfnlc(@distpobjfun, x0, @ellconstraint, o, E(i, j), X, E(i, j).shape); 
            else
              [x, fv] = ell_nlfnlc(@distpobjfun, x0, @ellconstraint, o, E(i, j), X); 
            end
        end
        dd = [dd -fv];
      end
      d = [d; dd];
    end
  else
    for i = 1:l
      y = X(:, i);
      switch ellOptions.nlcp_solver
        case 1, % use Optimization Toolbox routines
          o       = optimset('GradObj', 'on', 'GradConstr', 'on');
          if flag
            [x, fv] = fmincon(@distpobjfun, x0, [], [], [], [], [], [], @ellconstraint, o, E, y, E.shape); 
          else
            [x, fv] = fmincon(@distpobjfun, x0, [], [], [], [], [], [], @ellconstraint, o, E, y); 
          end
        otherwise,
          if flag
            [x, fv] = ell_nlfnlc(@distpobjfun, x0, @ellconstraint, o, E, y, E.shape); 
          else
            [x, fv] = ell_nlfnlc(@distpobjfun, x0, @ellconstraint, o, E, y); 
          end
      end
      d = [d -fv];
    end
  end

  status = [];

  return;





%%%%%%%%

function [d, status] = l_elldist(E, X, flag)
%
% L_ELLDIST - distance from ellipsoid to ellipsoid.
%

  global ellOptions;

  [m, n] = size(E);
  [k, l] = size(X);
  t1     = m * n;
  t2     = k * l;
  if (t1 > 1) & (t2 > 1) & ((m ~= k) | (n ~= l))
    error('DISTANCE: sizes of ellipsoidal arrays do not match.');
  end

  dims1 = dimension(E);
  dims2 = dimension(X);
  mn1   = min(min(dims1));
  mn2   = min(min(dims2));
  mx1   = max(max(dims1));
  mx2   = max(max(dims2));
  if (mn1 ~= mx1) | (mn2 ~= mx2) | (mn1 ~= mn2)
    error('DISTANCE: ellipsoids must be of the same dimension.');
  end

  if ellOptions.verbose > 0
    if (t1 > 1) | (t2 > 1)
      fprintf('Computing %d ellipsoid-to-ellipsoid distances...\n', max([t1 t2]));
    else
      fprintf('Computing ellipsoid-to-ellipsoid distance...\n');
    end
  end

  o.fungrad = 1;
  o.congrad = 1;
  %x0        = [1; zeros(mn1-1, 1)];
  x0        = rand(mn1, 1);
  x0        = x0/sqrt(x0'*x0);
  d         = [];
  if (t1 > 1) & (t2 > 1)
    for i = 1:m
      dd = [];
      for j = 1:n
        switch ellOptions.nlcp_solver
          case 1, % use Optimization Toolbox routines
            o       = optimset('GradObj', 'on', 'GradConstr', 'on');
            if flag
              [x, fv] = fmincon(@distobjfun, x0, [], [], [], [], [], [], @ellconstraint, o, E(i, j), X(i, j), E(i, j).shape); 
            else
              [x, fv] = fmincon(@distobjfun, x0, [], [], [], [], [], [], @ellconstraint, o, E(i, j), X(i, j)); 
            end
          otherwise,
            if flag
              [x, fv] = ell_nlfnlc(@distobjfun, x0, @ellconstraint, o, E(i, j), X(i, j), E(i, j).shape); 
            else
              [x, fv] = ell_nlfnlc(@distobjfun, x0, @ellconstraint, o, E(i, j), X(i, j)); 
            end
        end
        dd = [dd -fv];
      end
      d = [d; dd];
    end
  elseif (t1 > 1)
    for i = 1:m
      dd = [];
      for j = 1:n
        switch ellOptions.nlcp_solver
          case 1, % use Optimization Toolbox routines
            o       = optimset('GradObj', 'on', 'GradConstr', 'on');
            if flag
              [x, fv] = fmincon(@distobjfun, x0, [], [], [], [], [], [], @ellconstraint, o, E(i, j), X, E(i, j).shape); 
            else
              [x, fv] = fmincon(@distobjfun, x0, [], [], [], [], [], [], @ellconstraint, o, E(i, j), X); 
            end
          otherwise,
            if flag
              [x, fv] = ell_nlfnlc(@distobjfun, x0, @ellconstraint, o, E(i, j), X, E(i, j).shape); 
            else
              [x, fv] = ell_nlfnlc(@distobjfun, x0, @ellconstraint, o, E(i, j), X); 
            end
        end
        dd = [dd -fv];
      end
      d = [d; dd];
    end
  else
    for i = 1:k
      dd = [];
      for j = 1:l
        switch ellOptions.nlcp_solver
          case 1, % use Optimization Toolbox routines
            o       = optimset('GradObj', 'on', 'GradConstr', 'on');
            if flag
              [x, fv] = fmincon(@distobjfun, x0, [], [], [], [], [], [], @ellconstraint, o, E, X(i, j), E.shape); 
            else
              [x, fv] = fmincon(@distobjfun, x0, [], [], [], [], [], [], @ellconstraint, o, E, X(i, j)); 
            end
          otherwise,
            if flag
              [x, fv] = ell_nlfnlc(@distobjfun, x0, @ellconstraint, o, E, X(i, j), E.shape); 
            else
              [x, fv] = ell_nlfnlc(@distobjfun, x0, @ellconstraint, o, E, X(i, j)); 
            end
        end
        dd = [dd -fv];
      end
      d = [d; dd];
    end
  end

  status = [];

  return;





%%%%%%%%

function [d, status] = l_hpdist(E, X, flag)
%
% L_HPDIST - distance from ellipsoid to hyperplane.
%

  global ellOptions;

  [m, n] = size(E);
  [k, l] = size(X);
  t1     = m * n;
  t2     = k * l;
  if (t1 > 1) & (t2 > 1) & ((m ~= k) | (n ~= l))
    error('DISTANCE: sizes of ellipsoidal and hyperplane arrays do not match.');
  end

  dims1 = dimension(E);
  dims2 = dimension(X);
  mn1   = min(min(dims1));
  mn2   = min(min(dims2));
  mx1   = max(max(dims1));
  mx2   = max(max(dims2));
  if (mn1 ~= mx1)
    error('DISTANCE: ellipsoids must be of the same dimension.');
  end
  if (mn2 ~= mx2)
    error('DISTANCE: hyperplanes must be of the same dimension.');
  end

  if ellOptions.verbose > 0
    if (t1 > 1) | (t2 > 1)
      fprintf('Computing %d ellipsoid-to-hyperplane distances...\n', max([t1 t2]));
    else
      fprintf('Computing ellipsoid-to-hyperplane distance...\n');
    end
  end

  d = [];
  if (t1 > 1) & (t2 > 1)
    for i = 1:m
      dd = [];
      for j = 1:n
        [v, c] = parameters(X(i, j));
        if c < 0
          c = -c;
          v = -v;
        end
        if flag
          sr = sqrt(v' * (E(i, j).shape) * v);
	else
          sr = sqrt(v' * v);
	end
        if (v' * E(i, j).center) < c
          d1 = (c - rho(E(i, j), v))/sr;
        else
          d1 = (-c - rho(E(i, j), -v))/sr;
        end
        dd = [dd d1];
      end
      d = [d; dd];
    end
  elseif (t1 > 1)
    [v, c] = parameters(X);
    if c < 0
      c = -c;
      v = -v;
    end
    for i = 1:m
      dd = [];
      for j = 1:n
        if flag
          sr = sqrt(v' * (E(i, j).shape) * v);
	else
          sr = sqrt(v' * v);
	end
        if (v' * E(i, j).center) < c
          d1 = (c - rho(E(i, j), v))/sr;
        else
          d1 = (-c - rho(E(i, j), -v))/sr;
        end
        dd = [dd d1];
      end
      d = [d; dd];
    end
  else
    for i = 1:k
      dd = [];
      for j = 1:l
        [v, c] = parameters(X(i, j));
        if c < 0
          c = -c;
          v = -v;
        end
        if flag
          sr = sqrt(v' * (E.shape) * v);
	else
          sr = sqrt(v' * v);
	end
        if (v' * E.center) < c
          d1 = (c - rho(E, v))/sr;
        else
          d1 = (-c - rho(E, -v))/sr;
        end
        dd = [dd d1];
      end
      d = [d; dd];
    end
  end

  status = [];

  return;





%%%%%%%%

function [d, status] = l_polydist(E, X)
%
% L_POLYDIST - distance from ellipsoid to polytope.
%

  global ellOptions;

  [m, n] = size(E);
  [k, l] = size(X);
  t1     = m * n;
  t2     = k * l;
  if (t1 > 1) & (t2 > 1) & ((m ~= k) | (n ~= l))
    error('DISTANCE: sizes of ellipsoidal and polytope arrays do not match.');
  end

  dims1 = dimension(E);
  dims2 = [];
  for i = 1:k;
    dd = [];
    for j = 1:l
      dd = [dd dimension(X(j))];
    end
    dims2 = [dims2; dd];
  end
  mn1   = min(min(dims1));
  mn2   = min(min(dims2));
  mx1   = max(max(dims1));
  mx2   = max(max(dims2));
  if (mn1 ~= mx1)
    error('DISTANCE: ellipsoids must be of the same dimension.');
  end
  if (mn2 ~= mx2)
    error('DISTANCE: polytopes must be of the same dimension.');
  end

  if ellOptions.verbose > 0
    if (t1 > 1) | (t2 > 1)
      fprintf('Computing %d ellipsoid-to-polytope distances...\n', max([t1 t2]));
    else
      fprintf('Computing ellipsoid-to-polytope distance...\n');
    end
  end

  d = [];
  if (t1 > 1) & (t2 > 1)
    for i = 1:m
      dd = [];
      for j = 1:n
        [q, Q] = parameters(E(i, j));
        %[A, b] = double(X(i, j));
        [A, b] = double(X(j));
        if size(Q, 2) > rank(Q)
          Q = regularize(Q);
        end
        Q  = ell_inv(Q);
        Q  = 0.5*(Q + Q');
        x  = sdpvar(mx1, 1);
        y  = sdpvar(mx1, 1);
        f  = (y - x)'*(y - x);
        C  = set(x'*Q*x + 2*(-Q*q)'*x + (q'*Q*q - 1) <= 0);
        C  = C + set(A*y - b <= 0);
        o  = solvesdp(C, f, ellOptions.sdpsettings);
        d1 = double(f);
        if d1 < ellOptions.abs_tol
          d1 = 0;
        end
        d1 = sqrt(d1);
        dd = [dd d1];
      end
      d = [d; dd];
    end
  elseif (t1 > 1)
    [A, b] = double(X);
    for i = 1:m
      dd = [];
      for j = 1:n
        [q, Q] = parameters(E(i, j));
        if size(Q, 2) > rank(Q)
          Q = regularize(Q);
        end
        Q  = ell_inv(Q);
        Q  = 0.5*(Q + Q');
        x  = sdpvar(mx1, 1);
        y  = sdpvar(mx1, 1);
        f  = (y - x)'*(y - x);
        C  = set(x'*Q*x + 2*(-Q*q)'*x + (q'*Q*q - 1) <= 0);
        C  = C + set(A*y - b <= 0);
        o  = solvesdp(C, f, ellOptions.sdpsettings);
        d1 = double(f);
        if d1 < ellOptions.abs_tol
          d1 = 0;
        end
        d1 = sqrt(d1);
        dd = [dd d1];
      end
      d = [d; dd];
    end
  else
    [q, Q] = parameters(E);
    if size(Q, 2) > rank(Q)
      Q = regularize(Q);
    end
    Q = ell_inv(Q);
    Q = 0.5*(Q + Q');
    for i = 1:k
      dd = [];
      for j = 1:l
        %[A, b] = double(X(i, j));
        [A, b] = double(X(j));
        x  = sdpvar(mx1, 1);
        y  = sdpvar(mx1, 1);
        f  = (y - x)'*(y - x);
        C  = set(x'*Q*x + 2*(-Q*q)'*x + (q'*Q*q - 1) <= 0);
        C  = C + set(A*y - b <= 0);
        o  = solvesdp(C, f, ellOptions.sdpsettings);
        d1 = double(f);
        if d1 < ellOptions.abs_tol
          d1 = 0;
        end
        d1 = sqrt(d1);
        dd = [dd d1];
      end
      d = [d; dd];
    end
  end

  status = o;

  return;
