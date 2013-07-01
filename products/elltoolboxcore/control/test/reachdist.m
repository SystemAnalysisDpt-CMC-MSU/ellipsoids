  T  = 5;
  w  = 1;
  A  = [0 1; -w 0];
  %A  = {'0' '1'; '-1.5+cos(2*t)' '0'};
  B  = eye(2);
  C  = eye(2);
  C = [0; 1];
  U.center = {'sin(t)'; 'cos(t)'};
  U.shape =  [9 0; 0 2];
  V  = ellipsoid([1 -1; -1 3]);
  V  = ell_unitball(1);
  s  = linsys(A, B, U, C, V);
  %s  = linsys(A, B, U);
  
  X0 = ellipsoid([10; 0], [1 0; 0 1]);
  L0 = [1 -1; 1 1; 0 1]';
  L0 = [0 1; 1 -1; 1 2]';
 % L0 = [1 2]';
  o.save_all = 1;
  rs = reach(s, X0, L0, T, o);

  plotByEa(rs); hold on;
  plotByIa(rs);
