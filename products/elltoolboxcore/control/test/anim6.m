import elltool.conf.Properties;

Properties.setNPlot2dPoints(500);
Properties.setNTimeGridPoints(135);
aMat = {'0' '-10'; '1/(2 + sin(t))' '-4/(2 + sin(t))'};
bMat = {'10' '0'; '0' '1/(2 + sin(t))'};
SUBounds.center = {'10 -t'; '1'};
SUBounds.shape = {'4 - sin(t)' '-1'; '-1' '1 + (cos(t))^2'};
sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds);

x0EllObj = Properties.getAbsTol()*ell_unitball(2);

timeVec = [0 5];

dirsMat  = [1 0; 2 1; 1 1; 1 2; 0 1; -1 2; -1 1; -2 1]';
rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec);
[xx, tt] = rsObj.get_goodcurves();
xx = xx{7};

% clear MM;
% h = figure;
% 
% for i = 1:Properties.getNTimeGridPoints();
% 	cla;
% 	t0 = tt(i);
% 	t1 = t0 + T;
% 	x0 = xx(:, i);
% 	X0 = x0 + Properties.getAbsTol()*ell_unitball(2);
% 	rs = elltool.reach.ReachContinuous(s, X0, L0, [t0 t1]);
% 
% 	ct = rs.cut(t1);
% 	ct.plotByEa('r', 'fill', 1); hold on;
% 	ct.plotByIa('b', 'fill', 1);
% 	ell_plot(x0, 'k*');
% 	axis([-25 70 -5 14]);
% 
% 	hold off;
% 
% 	MM(i) = getframe(h);
% end
% 
% movie2avi(MM, 'reach_info.avi', 'QUALITY', 100);
