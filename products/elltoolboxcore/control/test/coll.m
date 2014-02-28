% Continuous-time system backward reachability test.

clear P;

  A        = [0 1; -2 0];
  B        = [0; 1];
  P.center = {'0'};
  P.shape  = 2;
  T        = 5;
  phi      = 0:0.1:pi;
  L0       = [cos(phi); sin(phi)];
  %L0       = [1 0; 0 1; 1 1; -1 1; -1 -1]';
  X0        = 0.00001*ell_unitball(2) + [3;1];
  M         = 0.00001*ell_unitball(2) + [2;0];

%   o.approximation = 0;
  sys      = elltool.linsys.LinSysContinuous(A, B, P);
  rs       = elltool.reach.ReachContinuous(sys, X0, L0, [0 T],  'isRegEnabled',true, 'isJustCheck', false ,'regTol',1e-4);

  dd = rs.get_directions();
  n = size(dd, 2);
  L1 = [];
  for i = 1:n
    d  = dd{i};
    L1 = [L1 d(:,end)];
  end
  brs      = elltool.reach.ReachContinuous(sys, M, L1, [T 0],  'isRegEnabled',true, 'isJustCheck', false ,'regTol',1e-4);

  plotByEa(rs); hold on;
  plotByEa(brs, 'g'); hold on;


  [gc1, t1] = rs.cut([0 0.886]).get_goodcurves();  gc1 = gc1{1};
  [gc2, t2] = brs.cut([T 0.886]).get_goodcurves(); gc2 = gc2{28};
  bc = brs.cut([T 0.886]).get_center();
  gc2 = 2*bc - gc2;

  ell_plot([t1;gc1], 'r'); hold on;
  ell_plot([t2;gc2], 'k'); hold on;

  t  = 0.886;
  gc = rs.cut(t).get_goodcurves(); gc = gc{1};
  ell_plot([t;gc], 'ro');
  ell_plot([0;3;1],'r*');
  ell_plot([T;2;0],'k*');
