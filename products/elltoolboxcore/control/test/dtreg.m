% Test for discrete-time lin. regularization.

  N  = 20;
  
  Ad = [0 1; 0 0];
  B  = [0; 1];
  P  = ellipsoid(0, 1);
  X0 = ell_unitball(2);
  phi = 0:0.1:pi;
  L0  = [cos(phi); sin(phi)];
  
  ds = elltool.linsys.LinSysDiscrete(Ad, B, P, [], [], [], [], 'd');
  
  rs = elltool.reach.ReachDiscrete(ds, X0, L0, [0 N],'isRegEnabled',true, 'isJustCheck', false ,'regTol',1e-6);
  E  = rs.get_ea();
  I  = rs.get_ia();
  
