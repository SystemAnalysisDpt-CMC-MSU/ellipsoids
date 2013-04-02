for k = 1:20
   A = {'0' '1 + cos(pi*k/2)'; '-2' '0'};
   B = [0; 1];
   U = ellipsoid(4);
   G = [1; 0];
   V = 1/(k+1);
   C = [1 0];
   lsys = elltool.linsys.LinSys(A, B, U, G, V, C, [], 'd');
end