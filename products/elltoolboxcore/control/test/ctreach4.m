  T = [0 5];
  A = [0 1 0 0; -1 0 1 0; 0 0 0 1; 0 0 -1 0];
  B = [0; 0; 0; 1];

  X0 = ell_unitball(4) + [1; 1; 0; -1];
  U  = ellipsoid(1);

  s  = elltool.linsys.LinSysContinuous(A, B, U);

  L  = [1 1 0 1; 0 -1 1 0; -1 1 1 1; 0 0 -1 1]';
 % L  = [1 1 0 1; 0 -1 1 0; -1 1 1 1]';
  L  = eye(4);
%   o.save_all = 1;
  rs = elltool.reach.ReachContinuous(s, X0, L, T, 'isRegEnabled',true, 'isJustCheck', false ,'regTol',1e-3);
