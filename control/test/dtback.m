% Test for discrete-time lin. system backward reachability.

  o.save_all = 1;

  Ad  = [cos(1) -sin(1); sin(1) cos(1)];
  B   = [0; 1];
  P   = ellipsoid(0, 1);
  M   = ellipsoid([-1; 2], [4 -1; -1 1]);
  phi = 0:0.1:2*pi;
  L0  = [1 1 0 1; 1 -1 1 0];
  L0  = [cos(phi); sin(phi)];

  ds  = linsys(Ad, B, P, [], [], [], [], 'd');
  rs  = reach(ds, M, L0, [N 0], o);
  E   = get_ea(rs);
  I   = get_ia(rs);
  
  EA  = (Ad^(-N)) * M;
  for i = 1:N
    F  = Ad^(N-i);
    Fi = inv(F);
    EA = [EA Fi*inv(Ad)*B*P];
  end
