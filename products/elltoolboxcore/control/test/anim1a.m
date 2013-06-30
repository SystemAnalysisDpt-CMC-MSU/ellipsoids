dt = 1/24;
N = 24 * T/4;

h = figure;
for k = 1:N
  plotEa(cut(rs1, dt*(k-1)), 'fill', 0); hold on;
  plotIa(cut(rs1, dt*(k-1)), 'fill', 0); hold off;
  axis([-30 30 -7 7]);
  M(k) = getframe(h);
end
  
for k = (N+1):2*N
  plotEa(cut(rs2, dt*(k-1)), 'fill', 0); hold on;
  plotIa(cut(rs2, dt*(k-1)), 'fill', 0); hold off;
  axis([-30 30 -7 7]);
  M(k) = getframe(h);
end

for k = (2*N+1):3*N
  plotEa(cut(rs3, dt*(k-1)), 'fill', 0); hold on;
  plotIa(cut(rs3, dt*(k-1)), 'fill', 0); hold off;
  axis([-30 30 -7 7]);
  M(k) = getframe(h);
end

for k = (3*N+1):4*N
  plotEa(cut(rs4, dt*(k-1)), 'fill', 0); hold on;
  plotIa(cut(rs4, dt*(k-1)), 'fill', 0); hold off;
  axis([-30 30 -7 7]);
  M(k) = getframe(h);
end
