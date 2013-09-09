o.fill = 0;
dt = 1/24;
N = 24 * 5;

h = figure;
for k = 1:N
  plotByEa(cut(rs1, dt*(k-1)), 'b', o); hold on;
  plotByIa(cut(rs1, dt*(k-1)), 'y', o); hold off;
  axis([-50 50 -10 10]);
  M(k) = getframe(h);
end
  
for k = (N+1):2*N
  plotByEa(cut(rs2, dt*(k-1)), 'r', o); hold on;
  plotByIa(cut(rs2, dt*(k-1)), 'g', o); hold off;
  axis([-50 50 -10 10]);
  M(k) = getframe(h);
end

for k = (2*N+1):3*N
  plotByEa(cut(rs3, dt*(k-1)), 'm', o); hold on;
  plotByIa(cut(rs3, dt*(k-1)), 'c', o); hold off;
  axis([-50 50 -10 10]);
  M(k) = getframe(h);
end
