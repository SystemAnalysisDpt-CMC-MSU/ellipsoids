function [res, status] = intersect(E, X, s)
%
% INTERSECT - checks if the union or intersection of ellipsoids intersects
%             given ellipsoid, hyperplane or polytope.
%
%
% Description:
% ------------
%
% RES = INTERSECT(E, X, s)  Checks if the union (s = 'u') or intersection (s = 'i')
%                           of ellipsoids in E intersects with objects in X.
%                           X can be array of ellipsoids, array of hyperplanes,
%                           or array of polytopes.
%                           Ellipsoids, hyperplanes or polytopes in X must have
%                           the same dimension as ellipsoids in E.
%                           s = 'u' (default) - union of ellipsoids in E.
%                           s = 'i' - intersection.
%
%    If we need to check the intersection of union of ellipsoids in E (s = 'u'),
%    or if E is a single ellipsoid, it can be done by calling distance function
%    for each of the ellipsoids in E and X, and if it returns negative value,
%    the intersection is nonempty.
%    Checking if the intersection of ellipsoids in E (with size of E greater than 1)
%    intersects with ellipsoids or hyperplanes in X is more difficult.
%    This problem can be formulated as quadratically constrained quadratic
%    programming (QCQP) problem.
%    Let E(q, Q) be an ellipsoid with center q and shape matrix Q.
%    To check if this ellipsoid intersects (or touches) the intersection
%    of ellipsoids E(q1, Q1), E(q2, Q2), ..., E(qn, Qn), we define the QCQP
%    problem:
%                      J(x) = <(x - q), Q^(-1)(x - q)> --> min
%    with constraints:
%                       <(x - q1), Q1^(-1)(x - q1)> <= 1   (1)
%                       <(x - q2), Q2^(-1)(x - q2)> <= 1   (2)
%                       ................................
%                       <(x - qn), Qn^(-1)(x - qn)> <= 1   (n)
%
%    If this problem is feasible, i.e. inequalities (1)-(n) do not contradict,
%    or, in other words, intersection of ellipsoids E(q1, Q1), E(q2, Q2), ..., E(qn, Qn)
%    is nonempty, then we can find vector y such that it satisfies inequalities (1)-(n)
%    and minimizes function J. If J(y) <= 1, then ellipsoid E(q, Q) intersects
%    or touches the given intersection, otherwise, it does not.
%    To check if E(q, Q) intersects the union of E(q1, Q1), E(q2, Q2), ..., E(qn, Qn),
%    we compute the distances from this ellipsoids to those in the union. 
%    If at least one such distance is negative, then E(q, Q) does intersect
%    the union.
%
%    If we check the intersection of ellipsoids with hyperplane H(v, c),
%    it is enough to check the feasibility of the problem
%                        1'x --> min
%    with constraints (1)-(n), plus
%                      <v, x> - c = 0.
%
%    Checking the intersection of ellipsoids with polytope P(A, b) reduces
%    to checking the feasibility of the problem 
%                        1'x --> min
%    with constraints (1)-(n), plus
%                         Ax <= b.
%
%    We use YALMIP as interface to optimization tools.
%    (http://control.ee.ethz.ch/~joloef/yalmip.php)
%
%
% Output:
% -------
%
%    RES - result:
%           -1 - problem is infeasible,
%                for example, if s = 'i', but the intersection of ellipsoids in E
%                is an empty set;
%            0 - intersection is empty;
%            1 - if intersection is nonempty.
%
%     S   - (optional) status variable returned by YALMIP.
%
%
% See also:
% ---------
%
%    ELLIPSOID/ELLIPSOID, ISINSIDE, DISTANCE,
%    HYPERPLANE/HYPERPLANE, POLYTOPE/POLYTOPE,
%    YALMIP.
%

%
% Author:
% -------
%
%    Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
%    Vadim Kaushanskiy <vkaushanskiy@gmail.com>

  import elltool.conf.Properties;
  import modgen.common.throwerror

  if ~(isa(E, 'ellipsoid'))
    error('INTERSECT: first input argument must be ellipsoid.');
  end
  if ~(isa(X, 'ellipsoid')) & ~(isa(X, 'hyperplane')) & ~(isa(X, 'polytope'))
    error('INTERSECT: second input argument must be ellipsoid, hyperplane or polytope.');
  end

  if (nargin < 3) | ~(ischar(s))
    s = 'u';
  end

  if s == 'u'
    [m, n] = size(E);
    res    = (distance(E(1, 1), X) <= E(1,1).properties.absTol);
    for i = 1:m
      for j = 1:n
        if (i > 1) | (j > 1)
          res = res | (distance(E(i, j), X) <= E(i,j).properties.absTol);
        end
      end
    end
    status = [];
  elseif min(size(E) == [1 1]) == 1
    res    = (distance(E, X) <= E.properties.absTol);
    status = [];
  elseif isa(X, 'ellipsoid')
    dims = dimension(E);
    m    = min(min(dims));
    n    = max(max(dims));
    dims = dimension(X);
    k    = min(min(dims));
    l    = max(max(dims));
    if (m ~= n) | (k ~= l) | (k ~= m)
      error('INTERSECT: ellipsoids must be of the same dimension.');
    end
    if Properties.getIsVerbose()
      fprintf('Invoking CVX...\n');
    end
    [m, n] = size(X);
    res    = [];
    status = [];
    for i = 1:m
      r = [];
      s = [];
      for j = 1:n
        [rr, ss] = qcqp(E, X(i, j));
        r        = [r rr];
	s        = [s ss];
      end
      res    = [res; r];
      status = [status; s];
    end
  elseif isa(X, 'hyperplane')
    dims = dimension(E);
    m    = min(min(dims));
    n    = max(max(dims));
    dims = dimension(X);
    k    = min(min(dims));
    l    = max(max(dims));
    if (m ~= n) | (k ~= l) | (k ~= m)
      error('INTERSECT: ellipsoids and hyperplanes must be of the same dimension.');
    end
    if Properties.getIsVerbose()
      fprintf('Invoking CVX...\n');
    end
    [m, n] = size(X);
    res    = [];
    status = [];
    for i = 1:m
      r = [];
      s = [];
      for j = 1:n
        [rr, ss] = lqcqp(E, X(i, j));
        r        = [r rr];
        s        = [s ss];
      end
      res    = [res; r];
      status = [status; s];
    end
  else
    [m, n] = size(X);
    dims   = dimension(E);
    mm     = min(min(dims));
    nn     = max(max(dims));
    dims   = [];
    for i = 1:m
      dd = [];
      for j = 1:n
        dd = [dd dimension(X(j))];
      end
      dims = [dims; dd];
    end
    k = min(min(dims));
    l = max(max(dims));
    if (mm ~= nn) | (k ~= l) | (k ~= mm)
      error('INTERSECT: ellipsoids and polytopes must be of the same dimension.');
    end
    if Properties.getIsVerbose()
      fprintf('Invoking CVX...\n');
    end
    res    = [];
    status = [];
    for i = 1:m
      r = [];
      s = [];
      for j = 1:n
        [rr, ss] = lqcqp2(E, X(j));
        r        = [r rr];
        s        = [s ss];
      end
      res    = [res; r];
      status = [status; s];
    end
  end

  if nargout < 2
    clear status;
  end

  return;





%%%%%%%%

function [res, status] = qcqp(EA, E)
%
% QCQP - formulate quadratically constrained quadratic programming problem
%        and invoke external solver.
%
  import modgen.common.throwerror;
  import elltool.conf.Properties;
  status = 1;
  [q, Q] = parameters(E(1, 1));
  if size(Q, 2) > rank(Q)
    if Properties.getIsVerbose()
      fprintf('QCQP: Warning! Degenerate ellipsoid.\n');
      fprintf('      Regularizing...\n');
    end
    Q = regularize(Q,E(1,1).properties.absTol);
  end
  Q = ell_inv(Q);
  Q = 0.5*(Q + Q');
  QQ = Q;
  qq = q;
  %cvx
  [m, n] = size(EA);


  cvx_begin sdp
    variable x(length(Q), 1)
    minimize(x'*Q*x + 2*(-Q*q)'*x + (q'*Q*q - 1))
    subject to      
        for i = 1:m
            for j = 1:n
                [q, Q] = parameters(EA(i, j));
                if size(Q, 2) > rank(Q)
                    Q = regularize(Q,E(i,j).properties.absTol);
                end
                Q = ell_inv(Q);
                Q = 0.5*(Q + Q');
                x'*Q*x + 2*(-Q*q)'*x + (q'*Q*q - 1) <= 0;
            end
         end

  cvx_end
  if strcmp(cvx_status,'Infeasible') || strcmp(cvx_status,'Inaccurate/Infeasible')
      res = -1;
      return;
  end;
  if x'*QQ*x + 2*(-QQ*qq)'*x + (qq'*QQ*qq - 1) <= Properties.getAbsTol()
      res = 1;
  else
      res = 0;
  end;


  return;





%%%%%%%%

function [res, status] = lqcqp(EA, H)
%
% LQCQP - formulate quadratic programming problem with linear and quadratic constraints,
%         and invoke external solver.
%
  import modgen.common.throwerror;
  import elltool.conf.Properties;
  status = 1;
  [v, c] = parameters(H);
  if c < 0
    c = -c;
    v = -v;
  end
  
  %cvx
  [m, n] = size(EA);


  cvx_begin sdp
    variable x(size(v, 1), 1)
    minimize(abs(v'*x - c))
    subject to      
        for i = 1:m
            for j = 1:n
                [q, Q] = parameters(EA(i, j));
                if size(Q, 2) > rank(Q)
                    Q = regularize(Q,EA(i,j).properties.absTol);
                end
                Q  = ell_inv(Q);
                x'*Q*x - 2*q'*Q*x + (q'*Q*q - 1) <= 0;
            end
        end

  cvx_end
  if strcmp(cvx_status,'Infeasible') || strcmp(cvx_status, 'Inaccurate/Infeasible')
      res = -1;
      return;
  end;
  
  
  if abs(v'*x - c) <= Properties.getAbsTol()
      res = 1;
  else
      res = 0;
  end;

  return;





%%%%%%%%

function [res, status] = lqcqp2(EA, P)
%
% LQCQP2 - formulate quadratic programming problem with linear and quadratic constraints,
%         and invoke external solver.
%
  import modgen.common.throwerror;
  import elltool.conf.Properties;
  status = 1;
  [A, b] = double(P);
  [m, n] = size(EA);
  
  cvx_begin sdp
    variable x(size(A, 2), 1)
    minimize(A(1, :)*x)
    subject to      
        for i = 1:m
            for j = 1:n
                [q, Q] = parameters(EA(i, j));
                if size(Q, 2) > rank(Q)
                    Q = regularize(Q,EA(i,j).properties.absTol);
                end
                Q  = ell_inv(Q);
                Q  = 0.5*(Q + Q');
                x'*Q*x - 2*q'*Q*x + (q'*Q*q - 1) <= 0;
            end
        end

  cvx_end
  
if strcmp(cvx_status,'Failed')
    throwerror('cvxError','Cvx failed');
end;
  if strcmp(cvx_status,'Infeasible') || strcmp(cvx_status,'Inaccurate/Infeasible')
      res = -1;
      return;
  end;
  if A(1, :)*x <= Properties.getAbsTol()
      res = 1;
  else
      res = 0;
  end;
  