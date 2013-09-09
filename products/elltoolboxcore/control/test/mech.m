 k1 = 50;
 k2 = 47;

 m1 = 1.5;
 m2 = 2;

 T = [5 0];

 X0 = 0.00001*ell_unitball(4) + [2; 3; 0; 0];

 U = 5*ell_unitball(2);
 V = 0.32*ell_unitball(2);

 A = [0 0 1 0; 0 0 0 1; -(k1+k2)/m1 k2/m1 0 0; k2/m2 -(k1+k2)/m2 0 0];
 B = [0 0; 0 0; 1/m1 0; 0 1/m2];
 %B = [1 0 0 0; 0 1 0 0; 0 0 1/m1 0; 0 0 0 1/m2];
 G = [0 0; 0 0; 1 0; 0 1];

 s = linsys(A, B, U);
% s = linsys(A, B, U, G, V);
 
 phi = 0:0.1:pi;
 L  = [1 0 1 0; 1 -1 0 0; 0 -1 0 1]';
 L  = [cos(phi); zeros(1,32); ones(1, 32); sin(phi)];
 L  = [-2 0 1 1; 0 -1 0 1]';
 rs = reach(s, X0, L, T);

 BB = [1 0 0 0; 0 1 0 0]';
 ps = projection(rs, BB);

 plotByEa(ps); hold on;
 plotByIa(ps); hold on;

