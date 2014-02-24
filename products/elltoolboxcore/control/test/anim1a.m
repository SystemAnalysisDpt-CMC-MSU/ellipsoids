
dt = 1/4;
N = 4 * T(2)/4;
for k = 1:N
  rs1.cut([0 dt*(k-1)]).plotByEa(); 
%   rs1.cut([0 dt*(k-1)]).plotByIa(); hold off;
%   axis([-20 20 -5 5]);
   pause(1);
  M(k) = getframe(gca);
  closereq;
end
  
% for k = (N+1):2*N
%   rs2.cut([0 dt*(k-1)]).plotByEa(); 
% %   rs2.cut([0 dt*(k-1)]).plotByIa(); hold off;
% %   axis([-20 20 -5 5]);
%   M(k) = getframe(gcf);
% end
% 
% for k = (2*N+1):3*N
%   rs3.cut([0 dt*(k-1)]).plotByEa(); 
% %   rs3.cut([0 dt*(k-1)]).plotByIa(); hold off;
% %   axis([-20 20 -5 5]);
%   M(k) = getframe(gcf);
% end
% 
% for k = (3*N+1):4*N
%   rs4.cut([0 dt*(k-1)]).plotByEa(); 
% %   rs4.cut([0 dt*(k-1)]).plotByIa(); hold off;
% %   axis([-20 20 -5 5]);
%   M(k) = getframe(gcf);
% end
