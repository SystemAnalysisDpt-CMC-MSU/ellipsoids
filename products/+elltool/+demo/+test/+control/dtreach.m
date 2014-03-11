function dtreach
% Test for discrete-time lin. system forward reachability.

  Ad = [cos(1) -sin(1); sin(1) cos(1)];
  Ad = [0 1; -1 -0.5];
  B  = [0; 1];
  P  = ellipsoid(-1, 1);
  X0 = ell_unitball(2) + [-2; 3];
  phi = 0:0.05:pi;
  L0  = [1 1 0 1; 1 -1 1 0];
  L  = [cos(phi); sin(phi)];
  N = [1 10];
  ds = elltool.linsys.LinSysDiscrete(Ad, B, P, [], [], [], [], 'd');
  rs = elltool.reach.ReachDiscrete(ds, X0, L0, N);

  rs.refine(L);
  rs.plotByEa(); hold on;
  rs.plotByIa();


  E  = rs.get_ea();
  I  = rs.get_ia();
  
  EA = (Ad^N(end)) * X0;
  for i = 1:N(end)
    EA = [EA (Ad^(N(end)-i))*B*P];
  end
end