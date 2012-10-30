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
%   D = DISTANCE(E, X, F)  Optional parameter F, if set to 1, indicates that
%                          the distance should be computed in the metric
%                          of ellipsoids in E. By default (F = 0), the distance
%                          is computed in Euclidean metric.
%
%    Negative distance value means
%      for ellipsoid and vector: vector belongs to the ellipsoid,
%      for ellipsoid and hyperplane: ellipsoid intersects the hyperplane.
%    Zero distance value means
%      for ellipsoid and vector: vector is a boundary point of the ellipsoid,
%      for ellipsoid and hyperplane: ellipsoid touches the hyperplane.
%
%    Distance between ellipsoid E and ellipsoid or polytope X is the optimal value
%    of the following problem:
%                               min |x - y|
%                  subject to:  x belongs to E, y belongs to X.
%    Zero distance means that intersection of E and X is nonempty.
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
    fprintf('Invoking CVX...\n');
  end

  d      = [];
  status = [];
  if (t > 1) & (t == l)
    for i = 1:m
      dd  = [];
      sts = [];
      for j = 1:n
        y      = X(:, i*j);
        [q, Q] = double(E(i, j));
        Qi     = ell_inv(Q);
        Qi     = 0.5*(Qi + Qi');
        dst    = (q - y)'*Qi*(q - y) - 1;
        o      = struct('yalmiptime', [], 'solvertime', [], 'info', [], 'problem', [], 'dimacs', []);
        if dst > 0
            cvx_begin sdp
                variable x(mx, 1)
                if flag
                    f = (x - y)'*Qi*(x - y);
                else
                    f = (x - y)'*(x - y);
                end
                minimize(f)
                subject to
                    x'*Qi*x + 2*(-Qi*q)'*x + (q'*Qi*q - 1) <= 0
            cvx_end
            
         
          dst = f;
          if dst < ellOptions.abs_tol
            dst = 0;
          end
          dst = sqrt(dst);
        end
        dd  = [dd dst];
	sts = [sts cvx_status];
      end
      d      = [d; dd];
      status = [status sts];
    end
  elseif (t > 1)
    for i = 1:m
      dd  = [];
      sts = [];
      for j = 1:n
        y      = X;
        [q, Q] = double(E(i, j));
        Qi     = ell_inv(Q);
        Qi     = 0.5*(Qi + Qi');
        dst    = (q - y)'*Qi*(q - y) - 1;
        o      = struct('yalmiptime', [], 'solvertime', [], 'info', [], 'problem', [], 'dimacs', []);
        if dst > 0
            cvx_begin sdp
                variable x(mx, 1)
                if flag
                    f = (x - y)'*Qi*(x - y);
                else
                    f = (x - y)'*(x - y);
                end
                minimize(f)
                subject to
                    x'*Qi*x + 2*(-Qi*q)'*x + (q'*Qi*q - 1) <= 0
            cvx_end
  
          dst = f;
          if dst < ellOptions.abs_tol
            dst = 0;
          end
          dst = sqrt(dst);
        end
        dd  = [dd dst];
	sts = [sts cvx_status];
      end
      d      = [d; dd];
      status = [status sts];
    end
  else
    for i = 1:l
      y      = X(:, i);
      [q, Q] = double(E);
      Qi     = ell_inv(Q);
      Qi     = 0.5*(Qi + Qi');
      dst    = (q - y)'*Qi*(q - y) - 1;
      o      = struct('yalmiptime', [], 'solvertime', [], 'info', [], 'problem', [], 'dimacs', []);
      if dst > 0
          
          cvx_begin sdp
            variable x(mx, 1)
            if flag
                f = (x - y)'*Qi*(x - y);
            else
                f = (x - y)'*(x - y);
            end
            minimize(f)
            subject to
                x'*Qi*x + 2*(-Qi*q)'*x + (q'*Qi*q - 1) <= 0
          cvx_end

        x = sdpvar(mx, 1);
        if flag
          f = (x - y)'*Qi*(x - y);
        else
          f = (x - y)'*(x - y);
        end
        dst = f;
        if dst < ellOptions.abs_tol
          dst = 0;
        end
        dst = sqrt(dst);
      end
      d      = [d dst];
      status = [status o];
    end
  end

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
    fprintf('Invoking CVX...\n');
  end

  d      = [];
  status = [];
  if (t1 > 1) & (t2 > 1)
    for i = 1:m
      dd  = [];
      sts = [];
      for j = 1:n
        [q, Q] = double(E(i, j));
        [r, R] = double(X(i, j));
        Qi     = ell_inv(Q);
        Qi     = 0.5*(Qi + Qi');
        Ri     = ell_inv(R);
        Ri     = 0.5*(Ri + Ri');
        cvx_begin sdp
            variable x(mx1, 1)
            variable y(mx1, 1)
            if flag
                f = (x - y)'*Qi*(x - y);
            else
                f = (x - y)'*(x - y);
            end
            minimize(f)
            subject to
                x'*Qi*x + 2*(-Qi*q)'*x + (q'*Qi*q - 1) <= 0
                y'*Ri*y + 2*(-Ri*r)'*y + (r'*Ri*r - 1) <= 0
        cvx_end

        dst = f;
        if dst < ellOptions.abs_tol
          dst = 0;
        end
        dst = sqrt(dst);
        dd  = [dd dst];
	sts = [sts cvx_status];
      end
      d      = [d; dd];
      status = [status sts];
    end
  elseif (t1 > 1)
    for i = 1:m
      dd  = [];
      sts = [];
      for j = 1:n
        [q, Q] = double(E(i, j));
        [r, R] = double(X);
        Qi     = ell_inv(Q);
        Qi     = 0.5*(Qi + Qi');
        Ri     = ell_inv(R);
        Ri     = 0.5*(Ri + Ri');
        cvx_begin sdp
            variable x(mx1, 1)
            variable y(mx1, 1)
            if flag
                f = (x - y)'*Qi*(x - y);
            else
                f = (x - y)'*(x - y);
            end
            minimize(f)
            subject to
                x'*Qi*x + 2*(-Qi*q)'*x + (q'*Qi*q - 1) <= 0
                y'*Ri*y + 2*(-Ri*r)'*y + (r'*Ri*r - 1) <= 0
        cvx_end

        dst = f;
        if dst < ellOptions.abs_tol
          dst = 0;
        end
        dst = sqrt(dst);
        dd  = [dd dst];
	sts = [sts cvx_status];
      end
      d      = [d; dd];
      status = [status sts];
    end
  else
    for i = 1:k
      dd  = [];
      sts = [];
      for j = 1:l
        [q, Q] = double(E);
        [r, R] = double(X(i, j));
        Qi     = ell_inv(Q);
        Qi     = 0.5*(Qi + Qi');
        Ri     = ell_inv(R);
        Ri     = 0.5*(Ri + Ri');
        cvx_begin sdp
            variable x(mx1, 1)
            variable y(mx1, 1)
            if flag
                f = (x - y)'*Qi*(x - y);
            else
                f = (x - y)'*(x - y);
            end
            minimize(f)
            subject to
                x'*Qi*x + 2*(-Qi*q)'*x + (q'*Qi*q - 1) <= 0
                y'*Ri*y + 2*(-Ri*r)'*y + (r'*Ri*r - 1) <= 0
        cvx_end

        dst = f;
        if dst < ellOptions.abs_tol
          dst = 0;
        end
        dst = sqrt(dst);
        dd  = [dd dst];
	sts = [sts cvx_status];
      end
      d      = [d; dd];
      status = [status sts];
    end
  end

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
    fprintf('Invoking CVX...\n');
  end

  d      = [];
  status = [];
  if (t1 > 1) & (t2 > 1)
    for i = 1:m
      dd  = [];
      sts = [];
      for j = 1:n
        [q, Q] = parameters(E(i, j));
        %[A, b] = double(X(i, j));
        [A, b] = double(X(j));
        if size(Q, 2) > rank(Q)
          Q = regularize(Q);
        end
        Q  = ell_inv(Q);
        Q  = 0.5*(Q + Q');
        cvx_begin sdp
            variable x(mx1, 1)
            variable y(mx1, 1)
            if flag
                f = (x - y)'*Qi*(x - y);
            else
                f = (x - y)'*(x - y);
            end
            minimize(f)
            subject to
                x'*Qi*x + 2*(-Qi*q)'*x + (q'*Qi*q - 1) <= 0
                A*y - b <= 0
        cvx_end

        d1 = f;
        if d1 < ellOptions.abs_tol
          d1 = 0;
        end
        d1  = sqrt(d1);
        dd  = [dd d1];
	sts = [sts cvx_status];
      end
      d      = [d; dd];
      status = [status sts];
    end
  elseif (t1 > 1)
    [A, b] = double(X);
    for i = 1:m
      dd  = [];
      sts = [];
      for j = 1:n
        [q, Q] = parameters(E(i, j));
        if size(Q, 2) > rank(Q)
          Q = regularize(Q);
        end
        Q  = ell_inv(Q);
        Q  = 0.5*(Q + Q');
        cvx_begin sdp
            variable x(mx1, 1)
            variable y(mx1, 1)
            if flag
                f = (x - y)'*Qi*(x - y);
            else
                f = (x - y)'*(x - y);
            end
            minimize(f)
            subject to
                x'*Qi*x + 2*(-Qi*q)'*x + (q'*Qi*q - 1) <= 0
                A*y - b <= 0
        cvx_end

        d1 = f;
        if d1 < ellOptions.abs_tol
          d1 = 0;
        end
        d1  = sqrt(d1);
        dd  = [dd d1];
	sts = [sts cvx_status];
      end
      d      = [d; dd];
      status = [status sts];
    end
  else
    [q, Q] = parameters(E);
    if size(Q, 2) > rank(Q)
      Q = regularize(Q);
    end
    Q = ell_inv(Q);
    Q = 0.5*(Q + Q');
    for i = 1:k
      dd  = [];
      sts = [];
      for j = 1:l
        %[A, b] = double(X(i, j));
        [A, b] = double(X(j));
        cvx_begin sdp
            variable x(mx1, 1)
            variable y(mx1, 1)
            if flag
                f = (x - y)'*Qi*(x - y);
            else
                f = (x - y)'*(x - y);
            end
            minimize(f)
            subject to
                x'*Qi*x + 2*(-Qi*q)'*x + (q'*Qi*q - 1) <= 0
                A*y - b <= 0
        cvx_end

        d1 = f;
        if d1 < ellOptions.abs_tol
          d1 = 0;
        end
        d1  = sqrt(d1);
        dd  = [dd d1];
	sts = [sts cvx_status];
      end
      d      = [d; dd];
      status = [status sts];
    end
  end

  return;
