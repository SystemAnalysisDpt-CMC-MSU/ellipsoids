
o.shade = 0.3;
dt = 1/24;

clear M;

h = figure;
for k = 1:48
  plotByEa(cut(rs1, dt*(k-1)), 'b', o); hold on;
  plotByIa(cut(rs1, dt*(k-1)), 'y'); hold off;
  axis([-20 20 -2 2 -30 30]);
  %campos([-10 -1 10]);
  campos([-20 -2 -30]);
  M(k) = getframe(h);
	cla;
end

for k = 49:120
  plotByEa(cut(rs2, dt*(k-1)), 'r', o); hold on;
  plotByIa(cut(rs2, dt*(k-1)), 'g'); hold off;
  axis([-20 20 -2 2 -30 30]);
  campos([-20 -2 -30]);
  M(k) = getframe(h);
	cla;
end

movie2avi(M, 'switch3_a.avi', 'Quality', 100);
