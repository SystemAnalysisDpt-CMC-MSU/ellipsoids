% Continuous-time system reachability test in 3D.

clear P;
o.save_all = 1;

  A        = {'sin(0.3*t)' '-0.22' '0'; '0' '-1' '0'; '-0.5' '1' 'cos(0.2*t)'};
  %A1       = [1 -1 0; 0 2 -1; 3 1 1];
  %A2        = [-1 0 0; 0 0 0; 0 0 0.2];
  B        = [0 1 1; 1 1 0; 1 0 1];
  P.center = {'sin(2*t)'; 'cos(2*t)'; '1'};
  P.shape  = [1 0 0; 0 2 0; 0 0 2];
  T        = [1 2];
  L0       = [1 0 0; 0 0 1;0 1 1;1 -1 1; 1 0 1; 1 1 0]';
  X0       = ell_unitball(3) + [1; -1; -1];

  sys      = linsys(A, B, P);
  rs       = reach(sys, X0, L0, T, o);

  E        = get_ea(rs);
  I        = get_ia(rs);
