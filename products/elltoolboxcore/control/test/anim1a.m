dt = 1/24;
N = 24 * T/4;

h = figure;
for k = 1:N
  plotByEa(cut(rs1, dt*(k-1)), 'fill', 0); hold on;
  plotByIa(cut(rs1, dt*(k-1)), 'fill', 0); hold off;
  axis([-30 30 -7 7]);
  M(k) = getframe(h);
end
  
for k = (N+1):2*N
  plotByEa(cut(rs2, dt*(k-1)), 'fill', 0); hold on;
  plotByIa(cut(rs2, dt*(k-1)), 'fill', 0); hold off;
  axis([-30 30 -7 7]);
  M(k) = getframe(h);
end

for k = (2*N+1):3*N
  plotByEa(cut(rs3, dt*(k-1)), 'fill', 0); hold on;
  plotByIa(cut(rs3, dt*(k-1)), 'fill', 0); hold off;
  axis([-30 30 -7 7]);
  M(k) = getframe(h);
end

for k = (3*N+1):4*N
  plotByEa(cut(rs4, dt*(k-1)), 'fill', 0); hold on;
  plotByIa(cut(rs4, dt*(k-1)), 'fill', 0); hold off;
  axis([-30 30 -7 7]);
  M(k) = getframe(h);
end
