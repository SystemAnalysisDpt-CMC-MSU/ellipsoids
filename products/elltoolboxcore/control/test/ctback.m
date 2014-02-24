% Continuous-time system backward reachability test.

clear P;

  A        = [0 1; 0 0];
  B        = [0; 1];
  P.center = {'0'};
  P.shape  = 2;
  T        = [4 2];
  phi      = 0:0.1:2*pi;
  L0       = [cos(phi); sin(phi)];
  L0       = [1 0; 0 1; 1 1; -1 1]';
  M        = 2*ell_unitball(2);

  sys      = elltool.linsys.LinSysContinuous(A, B, P);
  rs       = elltool.reach.ReachContinuous(sys, M, L0, T, 'isRegEnabled',true, 'isJustCheck', false ,'regTol',1e-3);

  E        = rs.get_ea();
  I        = rs.get_ia();
