
dt = 1/4;
N = 4 * T(2)/4;
for k = 1:N
  rs1.cut([0 dt*(k-1)]).plotByEa(); hold on;
  rs1.cut([0 dt*(k-1)]).plotByIa(); hold off;
%   axis([-20 20 -5 5]);
  M(k) = getframe();
end
  
for k = (N+1):2*N
  rs2.cut([0 dt*(k-1)]).plotByEa(); hold on;
  rs2.cut([0 dt*(k-1)]).plotByIa(); hold off;
%   axis([-20 20 -5 5]);
  M(k) = getframe();
end

for k = (2*N+1):3*N
  rs3.cut([0 dt*(k-1)]).plotByEa(); hold on;
  rs3.cut([0 dt*(k-1)]).plotByIa(); hold off;
%   axis([-20 20 -5 5]);
  M(k) = getframe();
end

for k = (3*N+1):4*N
  rs4.cut([0 dt*(k-1)]).plotByEa(); hold on;
  rs4.cut([0 dt*(k-1)]).plotByIa(); hold off;
%   axis([-20 20 -5 5]);
  M(k) = getframe();
end
