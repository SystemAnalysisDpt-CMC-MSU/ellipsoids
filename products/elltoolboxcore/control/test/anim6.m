import elltool.conf.Properties;

Properties.setNPlot2dPoints(500);
Properties.setNTimeGridPoints(135);
A = {'0' '-10'; '1/(2 + sin(t))' '-4/(2 + sin(t))'};
B = {'10' '0'; '0' '1/(2 + sin(t))'};
U.center = {'10 -t'; '1'};
U.shape = {'4 - sin(t)' '-1'; '-1' '1 + (cos(t))^2'};
s = linsys(A, B, U);

X0 = Properties.getAbsTol()*ell_unitball(2);

T = 5;

L0  = [1 0; 2 1; 1 1; 1 2; 0 1; -1 2; -1 1; -2 1]';
rs = reach(s, X0, L0, T);
[xx, tt] = get_goodcurves(rs);
xx = xx{7};

clear MM;
h = figure;

for i = 1:Properties.getNTimeGridPoints();
	cla;
	t0 = tt(i);
	t1 = t0 + T;
	x0 = xx(:, i);
	X0 = x0 + Properties.getAbsTol()*ell_unitball(2);
	rs = reach(s, X0, L0, [t0 t1]);

	ct = cut(rs, t1);
	plotByEa(ct, 'r', 'fill', 1); hold on;
	plotByIa(ct, 'b', 'fill', 1);
	ell_plot(x0, 'k*');
	axis([-25 70 -5 14]);

	hold off;

	MM(i) = getframe(h);
end

movie2avi(MM, 'reach_info.avi', 'QUALITY', 100);
