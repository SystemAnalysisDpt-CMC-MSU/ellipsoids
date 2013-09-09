% Test for discrete-time lin. system forward reachability.

  Ad = [cos(1) -sin(1); sin(1) cos(1)];
  Ad = [0 1; -1 -0.5];
  B  = [0; 1];
  P  = ellipsoid(-1, 1);
  X0 = ell_unitball(2) + [-2; 3];
  phi = 0:0.05:pi;
  L0  = [1 1 0 1; 1 -1 1 0];
  L  = [cos(phi); sin(phi)];
  
  o.save_all = 1;
  ds = linsys(Ad, B, P, [], [], [], [], 'd');
  rs = reach(ds, X0, L0, N,o);

  rs = refine(rs, L);
  plotByEa(rs); hold on;
  plotByIa(rs);


  E  = get_ea(rs);
  I  = get_ia(rs);
  
  EA = (Ad^N) * X0;
  for i = 1:N
    EA = [EA (Ad^(N-i))*B*P];
  end
