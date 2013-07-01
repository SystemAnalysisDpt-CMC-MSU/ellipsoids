import elltool.conf.Properties;

C = 1;
  A1 = {'sin(3*t)' '-0.22' '0'; '0' '-1' '0'; '-0.5' '1' 'cos(0.2*t)'};
  B1 = [0 1 0; 1 0 0;0 0 1];
  U1.center = [0; 0; 0];
  U1.shape = {'2 - sin(2*t)' '0' '0'; '0' '2- cos(3*t)' '0'; '0' '0' '1'};
  T  = [0 3];
  L0 = [1 0 0; 0 0 1;0 1 1;1 -1 1; 1 0 1; 1 1 0]';
  X0 = [4 -2 5]' +Properties.getAbsTol()*ell_unitball(3);

  s1 = linsys(A1, B1, U1);
  rs1 = reach(s1, X0, L0, T);

  [xx, tt] = get_goodcurves(rs1);
  xx = xx{1};

  clear MM;
  h = figure;
  for i = 1:200
	  cla;
    x0  = C * xx(:, i);
    X0  = x0 + Properties.getAbsTol()*ell_unitball(3);
    rs1 = reach(s1, X0, L0, [tt(i) (tt(i)+3)]);
    plotByEa(rs1, 'r'); hold on;
    plotByIa(rs1, 'b');
    ell_plot(x0, 'k*');
    axis([0 20 -2 2 0 80]);
    campos([0 -2 10]);
    hold off;

    MM(i) = getframe(h);
  end

  movie2avi(MM, 'reach_info3.avi', 'QUALITY', 100);
