import elltool.conf.Properties;

Properties.setNPlot2dPoints(1000)
aMat = {'0' '-10'; '1/(2 + sin(t))' '-4/(2 + sin(t))'};
bMat = {'10' '0'; '0' '1/(2 + sin(t))'};
%U = ell_unitball(2);
SUBounds = struct();
SUBounds.center = [0; 0];
SUBounds.shape = {'4 - sin(t)' '-1'; '-1' '1 + (cos(t))^2'};

x0EllObj = ell_unitball(2);
timeVec  = [0 20];
firstDirsMat = [1 1]';
secondDirsMat = [-1 1]';
thirdDirsMat = [0 1; 1 0]';
phi = 0:0.1:pi;
forthDirsMat = [cos(phi); sin(phi)];

firstSys  = elltool.linsys.LinSysContinuous(A, B, SUBounds);
firstRsObj = elltool.reach.ReachContinuous(firstSys, x0EllObj, firstDirsMat, timeVec);
secondRsObj = firstRsObj.refine(secondDirsMat);
thirdRsObj = secondRsObj.refine(thirdDirsMat);
forthRsObj = elltool.reach.ReachContinuous(firstSys, x0EllObj, forthDirsMat, timeVec);


% o.fill = 1;
% dt = 1/24;
% N = 24 * T(2)/4;
% 
% h = figure;
% for k = 1:N
%   plotByEa(cut(rs1, dt*(k-1))); hold on;
%   plotByIa(cut(rs1, dt*(k-1))); hold off;
%   axis([-20 20 -5 5]);
%   M(k) = getframe(h);
% end
%   
% for k = (N+1):2*N
%   plotByEa(cut(rs2, dt*(k-1))); hold on;
%   plotByIa(cut(rs2, dt*(k-1))); hold off;
%   axis([-20 20 -5 5]);
%   M(k) = getframe(h);
% end
% 
% for k = (2*N+1):3*N
%   plotByEa(cut(rs3, dt*(k-1))); hold on;
%   plotByIa(cut(rs3, dt*(k-1))); hold off;
%   axis([-20 20 -5 5]);
%   M(k) = getframe(h);
% end
% 
% for k = (3*N+1):4*N
%   plotByEa(cut(rs4, dt*(k-1))); hold on;
%   plotByIa(cut(rs4, dt*(k-1))); hold off;
%   axis([-20 20 -5 5]);
%   M(k) = getframe(h);
% end
