  A0 = [0.2 0 -0.4; 0 0 -0.6; 0 0.5 -1];
  A1 = [0.54 0 0.4; 0.06 0 0.6; 0.6 0 1];
  A  = [zeros(3, 3) eye(3); A0 A1];

  B1 = [-1.6 0.8; -2.4 0.2; -4 2];
  B  = [zeros(3, 2); B1];

  U.center = {'(k+7)/100'; '2'};
  U.shape  = [0.02 0; 0 1];

  X0 = ellipsoid([1; 0.5; -0.5; 1.10; 0.55; 0], eye(6));

  lsys = elltool.linsys.LinSysDiscrete(A, B, U, [], [], [], [], 'd');

  L0 = [1 0 0 0 0 0; 0 1 0 0 0 0; 0 0 1 0 0 1; 0 1 0 1 1 0; 0 0 -1 1 0 1; 0 0 0 -1 1 1]';
  rs = elltool.reach.ReachDiscrete(lsys, X0, L0, N,'isRegEnabled',true, 'isJustCheck', false ,'regTol',1e-4);

  BB = [0 0 0 0 1 0; 0 0 0 0 0 1]';
  ps = rs.projection(BB);
  
  ps.plotByEa(); hold on;
  ps.plotByIa(); hold on;
