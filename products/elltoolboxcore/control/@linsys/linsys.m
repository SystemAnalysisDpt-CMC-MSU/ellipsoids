function ls = linsys(A, B, U, G, V, C, W, D,varargin)
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
% $Author: Alex Kurzhanskiy  <akurzhan@eecs.berkeley.edu> $    $Date: 2004-2008 $
% $Copyright:  The Regents of the University of California 2004-2008 $
%
% $Author: Ivan Menshikov  <ivan.v.menshikov@gmail.com> $    $Date: 2012 $
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
   import elltool.conf.Properties;
   neededPropNameList = {'absTol'};
  absTol =  elltool.conf.parseProp(varargin,neededPropNameList);
  
  if nargin == 0
    ls.A              = [];
    ls.B              = [];
    ls.control        = [];
    ls.G              = [];
    ls.disturbance    = [];
    ls.C              = [];
    ls.noise          = [];
    ls.lti            = false;
    ls.dt             = false;
    ls.constantbounds = false(1,3);
    ls.absTol = absTol;
    ls                = class(ls, 'linsys');
    return;
  end

  lti    = true;
  [m, n] = size(A);
  if m ~= n
    error('linsys:dimension:A', 'LINSYS: A must be square matrix.');
  end
  if iscell(A)
    lti = false;
  elseif ~(isa(A, 'double'))
    error('linsys:type:A', 'LINSYS: matrix A must be of type ''cell'' or ''double''.');
  end
  ls.A = A;
  
  [k, l] = size(B);
  if k ~= n
    error('linsys:dimension:B', 'LINSYS: dimensions of A and B do not match.');
  end
  if iscell(B)
    lti = false;
  elseif ~(isa(B, 'double'))
    error('linsys:type:B', 'LINSYS: matrix B must be of type ''cell'' or ''double''.');
  end 
  ls.B = B;
  
  cbu = true;
  if nargin > 2
    if isempty(U)
      % leave as is
    elseif isa(U, 'ellipsoid')
      U      = U(1, 1);
      [d, r] = dimension(U);
      if d ~= l
        error('linsys:dimension:U', 'LINSYS: dimensions of control bounds U and matrix B do not match.');
      end
      if (d > r) && (Properties.getIsVerbose())
        fprintf('LINSYS: Warning! Control bounds U represented by degenerate ellipsoid.\n');
      end
    elseif isa(U, 'double') || iscell(U)
      [k, m] = size(U);
      if m > 1
        error('linsys:type:U', 'LINSYS: control U must be an ellipsoid or a vector.')
      elseif k ~= l
        error('linsys:dimension:U', 'LINSYS: dimensions of control vector U and matrix B do not match.');
      end
      if iscell(U)
          cbu = false;
      end
    elseif isstruct(U) && isfield(U, 'center') && isfield(U, 'shape')
      cbu = false;
      U   = U(1, 1);
      l_check_ell_struct(U, l);      
    else
      error('linsys:type:U', 'LINSYS: control U must be an ellipsoid or a vector.')
    end
  else
    U = [];
  end
  ls.control = U;

  if nargin > 3
    if isempty(G)
      % leave as is
    else
      [k, l] = size(G);
      if k ~= n
        error('linsys:dimension:G', 'LINSYS: dimensions of A and G do not match.');
      end
      if iscell(G)
        lti = false;
      elseif ~(isa(G, 'double'))
        error('linsys:type:G', 'LINSYS: matrix G must be of type ''cell'' or ''double''.');
      end 
    end 
  else
    G = [];
  end

  cbv = true;
  if nargin > 4
    if isempty(G) || isempty(V)
      G = [];
      V = [];
    elseif isa(V, 'ellipsoid')
      V      = V(1, 1);
      [d, r] = dimension(V);
      if d ~= l
        error('linsys:dimension:V', 'LINSYS: dimensions of disturbance bounds V and matrix G do not match.');
      end
    elseif isa(V, 'double') || iscell(V)
      [k, m] = size(V);
      if m > 1
        error('linsys:type:V', 'LINSYS: disturbance V must be an ellipsoid or a vector.')
      elseif k ~= l
        error('linsys:dimension:V', 'LINSYS: dimensions of disturbance vector V and matrix G do not match.');
      end
      if iscell(V)
          cbv = false;
      end
    elseif isstruct(V) && isfield(V, 'center') && isfield(V, 'shape')
      cbv = false;
      V   = V(1, 1);
      l_check_ell_struct(V, l);
    else
      error('linsys:type:V', 'LINSYS: disturbance V must be an ellipsoid or a vector.')
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
        error('linsys:dimension:C', 'LINSYS: dimensions of A and C do not match.');
      end
      if iscell(C)
        lti = false;
      elseif ~(isa(C, 'double'))
        error('linsys:type:C', 'LINSYS: matrix C must be of type ''cell'' or ''double''.');
      end 
    end 
  else
    C = eye(n);
  end
  ls.C = C;
  
  cbw = true;
  if nargin > 6
    if isempty(W)
      % leave as is
    elseif isa(W, 'ellipsoid')
      W      = W(1, 1);
      [d, r] = dimension(W);
      if d ~= k
        error('linsys:dimension:W', 'LINSYS: dimensions of noise bounds W and matrix C do not match.');
      end
    elseif isa(W, 'double') || iscell(W)
      [l, m] = size(W);
      if m > 1
        error('linsys:type:W', 'LINSYS: noise W must be an ellipsoid or a vector.')
      elseif k ~= l
        error('linsys:dimension:W', 'LINSYS: dimensions of noise vector W and matrix C do not match.');
      end
      if iscell(W)
          cbw = false;
      end
    elseif isstruct(W) && isfield(W, 'center') && isfield(W, 'shape')
      cbw = false;
      W   = W(1, 1);
      l_check_ell_struct(W, k);
    else
      error('linsys:type:W', 'LINSYS: noise W must be an ellipsoid or a vector.')
    end
  else
    W   = [];
  end
  ls.noise = W;

  ls.lti = lti;
  ls.dt  = false;
  if (nargin > 7)  && ischar(D) && (D == 'd')
    ls.dt = true;
  end
  ls.constantbounds = [cbu cbv cbw];
  ls.absTol = absTol;
  ls                = class(ls, 'linsys');

end


%%%%%%%%

function l_check_ell_struct(E, N)
%
% L_CHECK_ELL_STRUCT - checks if given structure E represents an ellipsoid
%                      of dimension N.
%
  import elltool.conf.Properties;
  q   = E.center;
  Q   = E.shape;

  [k, l] = size(q);
  [m, n] = size(Q);
  if m ~= n
    error( sprintf('linsys:value:%s:shape',inputname(1)), ...
        'shape matrix must be symmetric, positive definite' );
  elseif n ~= N
    error( sprintf('linsys:dimension:%s:shape',inputname(1)), ...
        'shape matrix must be of dimension %dx%d', N, N );
  elseif l > 1 || k ~= N
    error( sprintf('linsys:dimension:%s:center',inputname(1)), ...
        'center must be a vector of dimension %d', N );  
  end 

  if ~iscell(q) && ~iscell(Q)
    error( sprintf('linsys:type:%s',inputname(1)), ...
        'for constant ellipsoids use ellipsoid object' );
  end

  if ~iscell(q) && ~isa(q, 'double')
    error( sprintf('linsys:type:%s:center',inputname(1)), ...
        'center must be of type ''cell'' or ''double''' );        
  end

  if iscell(Q)
    if Properties.getIsVerbose()
      fprintf('LINSYS: Warning! Cannot check if symbolic matrix is positive definite.\n');
    end
    isEqMat = strcmp(Q, Q.');
    if ~all( isEqMat(:) )
        error( sprintf('linsys:value:%s:shape',inputname(1)), ...
              'shape matrix must be symmetric, positive definite' );
    end
  else
    if isa(Q, 'double')
      isnEqMat = ( Q ~= Q.' );
      if any( isnEqMat(:) ) || min(eig(Q)) <= 0
        error( sprintf('linsys:value:%s:shape',inputname(1)), ...
            'shape matrix must be symmetric, positive definite' );
      end                    
    else
      error( sprintf('linsys:type:%s:shape',inputname(1)), ...
          'shape matrix must be of type ''cell'' or ''double''' );    
    end        
  end

end
