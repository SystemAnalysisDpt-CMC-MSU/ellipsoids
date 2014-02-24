% Continuous-time system reachability test.

clear P1;
  A        = [0 1; 0 0];
  A3  = [0 1; -2 0];
  A2 = {'0' '1-cos(2*t)'; '-2/(0.5+t)' '0'};
  B        = eye(2);
  B2  = [0; 1];
  P1.center = {'sin(t)'; 'cos(t)'};
  P1.center = {'1'; '-1'};
  P1.shape = [1 0; 0 1];
  P2.center = {'0'};
  P2.shape  = 1;
  V = ellipsoid(1);
  import elltool.conf.Properties;
  T        = [0 5];
  phi      = 0:0.1:pi;
  L0       = [cos(phi); sin(phi)];
  L0       = [1 0; 0 1; 1 1; -1 1]';
  %L0       = [1 0]';
  X0       = ell_unitball(2);

  sys      = elltool.linsys.LinSysContinuous(A3, B, P1);
  sys2     = elltool.linsys.LinSysContinuous(A2, B, P1);
  sys3     = elltool.linsys.LinSysContinuous(A, B, P1, B2, V);
  
  rs       = elltool.reach.ReachContinuous(sys, X0, L0, T, 'isRegEnabled',true, 'isJustCheck', false ,'regTol',1e-3);

  rs.plotByEa(); hold on;
%  plotByIa(rs); hold on;

  rs = rs.evolve(10, sys2);

  rs.plotByEa('r'); hold on;
%  plotByIa(rs, 'y'); hold on;
	  
  rs = rs.evolve(15, sys3);

  rs.plotByEa('g'); hold on;
%  plotByIa(rs, 'c'); hold on;
