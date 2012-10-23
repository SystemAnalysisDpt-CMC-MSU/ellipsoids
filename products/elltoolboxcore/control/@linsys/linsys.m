function ls = linsys(A, B, U, G, V, C, W, D)
%
% LINSYS - constructor for linear system object.
%
%
% Description:
% ------------
%
%    Continuous-time linear system:
%                   dx/dt  =  A(t) x(t)  +  B(t) u(t)  +  G(t) v(t)
%                    y(t)  =  C(t) x(t)  +  w(t)
%
%    Discrete-time linear system:
%                  x[k+1]  =  A[k] x[k]  +  B[k] u[k]  +  G[k] v[k]
%                    y[k]  =  C[k] x[k]  +  w[k]
%
%     x - state, vector in R^n.
%     u - control, vector in R^k.
%     v - disturbance, vector in R^l.
%     w - noise, vector in R^m.
%     y - output, vector in R^m.
%     A in R^(nxn), B in R^(nxk), G in R^(nxl) and C in R^(mxn).
%
%             S = LINSYS(A, B, U)    Defines linear system
%                                    dx/dt  =  A(t) x(t)  +  B(t) u(t)
%                                     y(t)  =  x(t)
%                                    where U defines ellipsoidal control bounds
%                                    U = E(p(t), P(t)). If p(t) and P(t) are
%                                    constant, parameter U should have type ellipsoid,
%                                    or be a fixed vector, otherwise U should be
%                                    a structure:
%                                          U.center - symbolic vector p(t),
%                                          U.shape  - symolic matrix P(t).
%                                    If U is empty, it means there are no bounds
%                                    on control.
%       S = LINSYS(A, B, U, G, V)    Defines linear system
%                                    dx/dt  =  A(t) x(t)  +  B(t) u(t)  +  G(t) v(t)
%                                     y(t)  =  x(t),
%                                    where V defines ellipsoidal disturbance bounds
%                                    V = E(q(t), Q(t)). If q(t) and Q(t) are
%                                    constant, parameter V should have type ellipsoid,
%                                    or be a fixed vector, otherwise V should be
%                                    a structure:
%                                          V.center - symbolic vector q(t),
%                                          V.shape  - symolic matrix Q(t).
%                                    If G and/or V is empty, it means there is no
%                                    disturbance.
%    S = LINSYS(A, B, U, G, V, C)    Defines linear system
%                                    dx/dt  =  A(t) x(t)  +  B(t) u(t)  +  G(t) v(t)
%                                     y(t)  =  C(t) x(t).
%                                    To consider the system without disturbance,
%                                    make G = [], V = [], Or, make G zero matrix.
% S = LINSYS(A, B, U, G, V, C, W)    Defines linear system
%                                    dx/dt  =  A(t) x(t)  +  B(t) u(t)  +  G(t) v(t)
%                                     y(t)  =  C(t) x(t)  +  W(t),
%                                    where W defines ellipsoidal noise bounds
%                                    W = E(r(t), R(t)). If r(t) and R(t) are
%                                    constant, parameter W should have type ellipsoid,
%                                    or be a fixed vector, otherwise W should be
%                                    a structure:
%                                          W.center - symbolic vector r(t),
%                                          W.shape  - symolic matrix R(t).
% S = LINSYS(A, B, U, G, V, C, W, D) If flag D is set to 'd', then linear system
%                                    is considered discrete-time:
%                                    x[k+1]  =  A[k] x[k]  +  B[k] u[k]  +  G[k] v[k]
%                                      y[k]  =  C[k] x[k]  +  W[k].
%                                    To define discrete-time system without
%                                    disturbance and/or noise, set G = [], V = [],
%                                    W = [].
%
%    In case one or more of the matrices A, B, G and C depend on time t,
%    they should be in symbolic form. For example, to represent matrix
%                                   _        _
%                          A(t) =  |  1   -t  |
%                                  |_ 0    1 _|,
%    type A = {'1' '-t'; '0' '1'}.
%    In discrete-time case, for 
%                                   _        _
%                          A[k] =  |  1   -k  |
%                                  |_ 0    1 _|
%    type A = {'1' '-k'; '0' '1'}.
%
%
% Output:
% -------
%
%    S - structure that describes linear system.
%    Following fields of structure S can be accessed directly:
%       S.A           - matrix A,
%       S.B           - matrix B,
%       S.G           - matrix G,
%       S.C           - matrix C,
%       S.control     - control bounds U,
%       S.disturbance - disturbance bounds V,
%       S.noise       - noise bounds W.
%
%
% See also:
% ---------
%
%    LINSYS/DIMENSION, ISEMPTY, ISDISCRETE, ISLTI, HASDISTURBANCE, HASNOISE.
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

  if nargin == 0
    ls.A              = [];
    ls.B              = [];
    ls.control        = [];
    ls.G              = [];
    ls.disturbance    = [];
    ls.C              = [];
    ls.noise          = [];
    ls.lti            = 0;
    ls.dt             = 0;
    ls.constantbounds = [0 0 0];
    ls                = class(ls, 'linsys');
    return;
  end

  lti    = 1;
  [m, n] = size(A);
  if m ~= n
    error('LINSYS: A must be square matrix.');
  end
  if iscell(A)
    lti = 0;
  elseif ~(isa(A, 'double'))
    error('LINSYS: matrix A must be of type ''cell'' or ''double''.');
  end
  ls.A = A;
  
  [k, l] = size(B);
  if k ~= n
    error('LINSYS: dimensions of A and B do not match.');
  end
  if iscell(B)
    lti = 0;
  elseif ~(isa(B, 'double'))
    error('LINSYS: matrix B must be of type ''cell'' or ''double''.');
  end 
  ls.B = B;
  
  cbu = 1;
  if nargin > 2
    if isempty(U)
      ; % leave as is
    elseif isa(U, 'ellipsoid')
      U      = U(1, 1);
      [d, r] = dimension(U);
      if d ~= l
        error('LINSYS: dimensions of control bounds U and matrix B do not match.');
      end
      if (d > r) & (ellOptions.verbose > 0)
        fprintf('LINSYS: Warning! Control bounds U represented by degenerate ellipsoid.\n');
      end
    elseif isa(U, 'double') | iscell(U)
      [k, m] = size(U);
      if m > 1
        error('LINSYS: control U must be an ellipsoid or a vector.')
      elseif k ~= l
        error('LINSYS: dimensions of control vector U and matrix B do not match.');
      end
    elseif isstruct(U) & isfield(U, 'center') & isfield(U, 'shape')
      cbu = 0;
      U   = U(1, 1);
      msg = l_check_ell_struct(U, l);
      if ~(isempty(msg))
        error(sprintf('LINSYS: control bounds U: %s.', msg));  
      end
    else
      error('LINSYS: control U must be an ellipsoid or a vector.')
    end
  else
    U = [];
  end
  ls.control = U;

  if nargin > 3
    if isempty(G)
      ; % leave as is
    else
      [k, l] = size(G);
      if k ~= n
        error('LINSYS: dimensions of A and G do not match.');
      end
      if iscell(G)
        lti = 0;
      elseif ~(isa(G, 'double'))
        error('LINSYS: matrix G must be of type ''cell'' or ''double''.');
      end 
    end 
  else
    G = [];
  end

  cbv = 1;
  if nargin > 4
    if isempty(G) | isempty(V)
      G = [];
      V = [];
    elseif isa(V, 'ellipsoid')
      V      = V(1, 1);
      [d, r] = dimension(V);
      if d ~= l
        error('LINSYS: dimensions of disturbance bounds V and matrix G do not match.');
      end
    elseif isa(V, 'double') | iscell(V)
      [k, m] = size(V);
      if m > 1
        error('LINSYS: disturbance V must be an ellipsoid or a vector.')
      elseif k ~= l
        error('LINSYS: dimensions of disturbance vector V and matrix G do not match.');
      end
    elseif isstruct(V) & isfield(V, 'center') & isfield(V, 'shape')
      cbv = 0;
      V   = V(1, 1);
      msg = l_check_ell_struct(V, l);
      if ~(isempty(msg))
        error(sprintf('LINSYS: disturbance bounds V: %s.', msg));  
      end
    else
      error('LINSYS: disturbance V must be an ellipsoid or a vector.')
    end
  else
    V = [];
  end
  ls.G           = G;
  ls.disturbance = V;

  if nargin > 5
    if isempty(C)
      C = eye(n);
    else
      [k, l] = size(C);
      if l ~= n
        error('LINSYS: dimensions of A and C do not match.');
      end
      if iscell(C)
        lti = 0;
      elseif ~(isa(C, 'double'))
        error('LINSYS: matrix C must be of type ''cell'' or ''double''.');
      end 
    end 
  else
    C = eye(n);
  end
  ls.C = C;
  
  cbw = 1;
  if nargin > 6
    if isempty(W)
      ; % leave as is
    elseif isa(W, 'ellipsoid')
      W      = W(1, 1);
      [d, r] = dimension(W);
      if d ~= k
        error('LINSYS: dimensions of noise bounds W and matrix C do not match.');
      end
    elseif isa(W, 'double') | iscell(W)
      [l, m] = size(W);
      if m > 1
        error('LINSYS: noise W must be an ellipsoid or a vector.')
      elseif k ~= l
        error('LINSYS: dimensions of noise vector W and matrix C do not match.');
      end
    elseif isstruct(W) & isfield(W, 'center') & isfield(W, 'shape')
      cbw = 0;
      W   = W(1, 1);
      msg = l_check_ell_struct(W, k);
      if ~(isempty(msg))
        error(sprintf('LINSYS: noise bounds W: %s.', msg));  
      end
    else
      error('LINSYS: noise W must be an ellipsoid or a vector.')
    end
  else
    W   = [];
  end
  ls.noise = W;

  ls.lti = lti;
  ls.dt  = 0;
  if (nargin > 7)  & ischar(D) & (D == 'd')
    ls.dt = 1;
  end
  ls.constantbounds = [cbu cbv cbw];
  ls                = class(ls, 'linsys');

  return;





%%%%%%%%

function msg = l_check_ell_struct(E, N)
%
% L_CHECK_ELL_STRUCT - checks if given structure E represents an ellipsoid
%                      of dimension N.
%

  global ellOptions;

  msg = '';
  q   = E.center;
  Q   = E.shape;

  [k, l] = size(q);
  [m, n] = size(Q);
  if m ~= n
    msg = 'shape matrix must be symmetric, positive definite';
    return;
  elseif n ~= N
    msg = sprintf('shape matrix must be of dimension %dx%d', N, N);
    return;
  elseif l > 1
    msg = sprintf('center must be a vector of dimension %d', N);
    return;
  elseif k ~= N
    msg = sprintf('center must be a vector of dimension %d', N);
    return;
  end 

  if ~(iscell(q)) & ~(iscell(Q))
    msg = 'for constant ellipsoids us ellipsoid object';
    return;
  end

  if ~(iscell(q))
    if ~(isa(q, 'double'))
      msg = 'center must be of type ''cell'' or ''double''';
      return;
    end
  end

  if ~(iscell(Q))
    if ~(isa(Q, 'double'))
      msg = 'shape matrix must be of type ''cell'' or ''double''';
      return;
    end
    if (Q ~= Q') | (min(eig(Q)) < 0)
      msg = 'shape matrix must be symmetric, positive definite';
      return;
    end
  else
    if ellOptions.verbose > 0
      fprintf('LINSYS: Warning! Cannot check if symbolic matrix is positive definite.\n');
    end
    for i = 1:n
      for j = i:n
	if min(Q{i, j} == Q{j, i}) < 1
          msg = 'shape matrix must be symmetric, positive definite';
          return;
        end
      end
    end
  end

  return; 
