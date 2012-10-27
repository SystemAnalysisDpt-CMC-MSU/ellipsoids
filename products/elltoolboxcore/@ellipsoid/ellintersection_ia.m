function [E, S] = ellintersection_ia(EE)
%
% ELLINTERSECTION_IA - computes maximum volume ellipsoid that is contained
%                      in the intersection of given ellipsoids.
%
%
% Description:
% ------------
%
%    E = ELLINTERSECTIONIA(EE)  Among all ellipsoids that are contained
%                               in the intersection of ellipsoids in EE,
%                               find the one that has maximal volume.
%
%
%     We use YALMIP as interface to the optimization tools.
%     (http://control.ee.ethz.ch/~joloef/yalmip.php)
%
%
% Output:
% -------
%
%    E - resulting maximum volume ellipsoid.
%    S - (optional) status variable returned by YALMIP.
%
%
% See also:
% ---------
%
%    ELLIPSOID/ELLIPSOID, ELLUNION_EA
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
    error('ELLINTERSECTION_IA: all ellipsoids must be of the same dimension.');
  end

  [m, n] = size(EE);
  M      = m * n;
  EE     = reshape(EE, 1, M);
  zz     = zeros(mn, 1);
  I      = eye(mn);

  if ellOptions.verbose > 0
    fprintf('Invoking YALMIP...\n');
  end

  B      = sdpvar(mn, mn);
  d      = sdpvar(mn, 1);
  ll     = sdpvar(M, 1);

  cnstr = lmi;

  for i = 1:M
    [q, Q] = double(EE(i));
    
    if rank(Q) < mn
      Q = regularize(Q);
    end
    
    A     = ell_inv(Q);
    b     = -A * q;
    c     = q' * A * q - 1;
    X     = [(-ll(i,1)-c+b'*Q*b) zz'       (d+Q*b)'
             zz                  ll(i,1)*I B
             (d+Q*b)             B         Q];

    cnstr = cnstr + set('X>=0');
    cnstr = cnstr + set('ll(i, 1)>=0');
  end
  ellOptions.sdpsettings = sdpsettings('solver','sedumi','sedumi.eps',1e-19, 'sedumi.numtol', 1.000000000000000e-11);
  S = solvesdp(cnstr, -logdet(B), ellOptions.sdpsettings);
  B = double(B);
  d = double(d);
  
  if rank(B) < mn
    B = regularize(B);
  end

  P = B * B';
  P = 0.5*(P + P');

  E = ellipsoid(d, P);

  if nargout < 2
    clear S;
  end

  return;
