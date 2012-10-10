function [E, S] = ellunion_ea(EE)
%
% ELLUNION_EA - computes minimum volume ellipsoid that contains union
%               of given ellipsoids.
%
%
% Description:
% ------------
%
%    E = ELLUNION_EA(EE)  Among all ellipsoids that contain the union
%                         of ellipsoids in the ellipsoidal array EE,
%                         find the one that has minimal volume.
%
%
%     We use YALMIP as interface to the optimization tools.
%     (http://control.ee.ethz.ch/~joloef/yalmip.php)
%
%
% Output:
% -------
%
%    E - resulting minimum volume ellipsoid.
%    S - (optional) status variable returned by YALMIP.
%
%
% See also:
% ---------
%
%    ELLIPSOID/ELLIPSOID, ELLINTERSECTION_IA.
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

  dims = dimension(EE);
  mn   = min(min(dims));
  mx   = max(max(dims));

  if mn ~= mx
    error('ELLUNION_EA: all ellipsoids must be of the same dimension.');
  end

  [m, n] = size(EE);
  M      = m * n;
  EE     = reshape(EE, 1, M);
  zz     = zeros(mn, mn);

  if ellOptions.verbose > 0
    fprintf('Invoking YALMIP...\n');
  end

  A      = sdpvar(mn, mn);
  b      = sdpvar(mn, 1);
  tt     = sdpvar(M, 1);

  cnstr = lmi;

  for i = 1:M
    [q, Q] = double(EE(i));
    
    if rank(Q) < mn
      Q = regularize(Q);
    end
    
    Q     = ell_inv(Q);
    bb    = -Q * q;
    cc    = q' * Q * q - 1;
    X     = [(A-tt(i,1)*Q)   (b-tt(i,1)*bb)  zz
             (b-tt(i,1)*bb)' (-1-tt(i,1)*cc) b'
             zz'             b               (-A)];
    cnstr = cnstr + set('X<=0');
    cnstr = cnstr + set('-tt(i, 1)<=0');
  end

  S = solvesdp(cnstr, -logdet(A), ellOptions.sdpsettings);
  A = double(A);
  b = double(b);
  
  B = sqrtm(A);
  P = ell_inv(B'*B);
  P = (1+ellOptions.abs_tol)*0.5*(P + P');

  A = ell_inv(A);
  p = -A * b;

  E = ellipsoid(p, P);

  if nargout < 2
    clear S;
  end

  return;
  
