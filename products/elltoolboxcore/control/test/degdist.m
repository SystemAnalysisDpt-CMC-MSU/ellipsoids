  T  = 5;
  w  = 2;
  A  = [0 1; -w 0];
  B  = eye(2);
  C  = eye(2);
  U  = ellipsoid([0.9 0; 0 0.1]);
  V  = ellipsoid([36 0; 0 49]);
  s  = linsys(A, B, U, C, V);
  
  X0 = ellipsoid([10; 0], [0.5 0; 0 0.5]);
  L0 = [1 -1; 1 1; 0 1; 1 0]';
  L0 = [1 1; 1 -1]';
  rs = reach(s, X0, L0, T);
