% Continuous-time system reachability test.

  A        = {'2' '0'; '0' 't'};
  B        = {'0' 'exp(t)'; 'sqrt(t)' '0'};
  P = ell_unitball(2);
  import elltool.conf.Properties;
  T        = [1.1 2];
  phi      = 0:0.1:pi;
  L0       = [cos(phi); sin(phi)];
  L0       = [1 0; 0 1; 1 1; -1 1]';
  %L0       = [1 1; 1 -1]';
  X0       = ell_unitball(2) + [1; -1];

  sys      = linsys(A, B, P);
  rs       = reach(sys, X0, L0, T);

  plotByEa(rs); hold on;
  plotByIa(rs); hold on;

	  
