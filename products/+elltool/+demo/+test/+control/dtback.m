function dtback
% Test for discrete-time lin. system backward reachability.


  Ad  = [cos(1) -sin(1); sin(1) cos(1)];
  B   = [0; 1];
  P   = ellipsoid(0, 1);
  M   = ellipsoid([-1; 2], [4 -1; -1 1]);
  N = 20;
%   phi = 0:0.1:2*pi;
  L0  = [1 1 0 1; 1 -1 1 0];
%   L0  = [cos(phi); sin(phi)];

  ds  = elltool.linsys.LinSysDiscrete(Ad, B, P, [], [], [], [], 'd');
  rs  = elltool.reach.ReachDiscrete(ds, M, L0, [N 0]);
  E   = rs.get_ea();
  I   = rs.get_ia();
  
  EA  = (Ad^(-N)) * M;
  for i = 1:N
    F  = Ad^(N-i);
    Fi = inv(F);
    EA = [EA Fi*inv(Ad)*B*P];
  end

  
end