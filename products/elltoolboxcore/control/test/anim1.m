import elltool.conf.Properties;

Properties.setNPlot2dPoints(1000)
A = {'0' '-10'; '1/(2 + sin(t))' '-4/(2 + sin(t))'};
B = {'10' '0'; '0' '1/(2 + sin(t))'};
%U = ell_unitball(2);
U.center = [0; 0];
U.shape = {'4 - sin(t)' '-1'; '-1' '1 + (cos(t))^2'};

X0 = ell_unitball(2);
T  = 20;
L1 = [1 1]';
L2 = [-1 1]';
L3 = [0 1; 1 0]';
phi = 0:0.1:pi;
L4 = [cos(phi); sin(phi)];

opt.save_all =1;
s1  = linsys(A, B, U);
rs1 = reach(s1, X0, L1, T, opt);
rs2 = refine(rs1, L2);
rs3 = refine(rs2, L3);
rs4 = reach(s1, X0, L4, T);


o.fill = 1;
dt = 1/24;
N = 24 * T/4;

h = figure;
for k = 1:N
  plotByEa(cut(rs1, dt*(k-1))); hold on;
  plotByIa(cut(rs1, dt*(k-1))); hold off;
  axis([-20 20 -5 5]);
  M(k) = getframe(h);
end
  
for k = (N+1):2*N
  plotByEa(cut(rs2, dt*(k-1))); hold on;
  plotByIa(cut(rs2, dt*(k-1))); hold off;
  axis([-20 20 -5 5]);
  M(k) = getframe(h);
end

for k = (2*N+1):3*N
  plotByEa(cut(rs3, dt*(k-1))); hold on;
  plotByIa(cut(rs3, dt*(k-1))); hold off;
  axis([-20 20 -5 5]);
  M(k) = getframe(h);
end

for k = (3*N+1):4*N
  plotByEa(cut(rs4, dt*(k-1))); hold on;
  plotByIa(cut(rs4, dt*(k-1))); hold off;
  axis([-20 20 -5 5]);
  M(k) = getframe(h);
end
