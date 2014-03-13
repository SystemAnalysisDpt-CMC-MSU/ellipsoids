% Test for discrete-time lin. regularization.

  o.save_all = 1;

  N  = 20;
  
  Ad = [0 1; 0 0];
  B  = [0; 1];
  P  = ellipsoid(0, 1);
  X0 = ell_unitball(2);
  phi = 0:0.1:pi;
  L0  = [1 1 0 1; 1 -1 1 0];
  L0  = [cos(phi); sin(phi)];
  
  ds = linsys(Ad, B, P, [], [], [], [], 'd');
  rs = reach(ds, X0, L0, N, o);
  E  = get_ea(rs);
  I  = get_ia(rs);
  
