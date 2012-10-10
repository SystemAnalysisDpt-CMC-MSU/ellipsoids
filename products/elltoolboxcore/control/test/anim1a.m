o.fill = 0;
dt = 1/24;
N = 24 * T/4;

h = figure;
for k = 1:N
  plot_ea(cut(rs1, dt*(k-1)), o); hold on;
  plot_ia(cut(rs1, dt*(k-1)), o); hold off;
  axis([-30 30 -7 7]);
  M(k) = getframe(h);
end
  
for k = (N+1):2*N
  plot_ea(cut(rs2, dt*(k-1)), o); hold on;
  plot_ia(cut(rs2, dt*(k-1)), o); hold off;
  axis([-30 30 -7 7]);
  M(k) = getframe(h);
end

for k = (2*N+1):3*N
  plot_ea(cut(rs3, dt*(k-1)), o); hold on;
  plot_ia(cut(rs3, dt*(k-1)), o); hold off;
  axis([-30 30 -7 7]);
  M(k) = getframe(h);
end

for k = (3*N+1):4*N
  plot_ea(cut(rs4, dt*(k-1)), o); hold on;
  plot_ia(cut(rs4, dt*(k-1)), o); hold off;
  axis([-30 30 -7 7]);
  M(k) = getframe(h);
end
