import elltool.conf.Properties;

C =0.25;
 A = [0 1; 0 0]; B = [0; 1]; U = ellipsoid(1);
 s = linsys(A, B, U);

 X0 = Properties.getAbsTol()*ell_unitball(2);

 L0 = [-1 -1; 1 0; 0 1; 2 1; 3 1; 1 3; 1 2; -1 1; -2 1; -3 1; -1 3; -1 2]';

 T = 6;
 o.approximation = 0;
 rs = reach(s, X0, L0, T, o);
 EA = get_ea(cut(rs, T));

    EA  = inv(EA');
    M   = size(EA, 2);
    N   = Properties.getNPlot2dPoints()/2;
    phi = linspace(0, 2*pi, N);
    L   = [cos(phi); sin(phi)];
    yy  = [];
    for i = 1:N
      l    = L(:, i);
      mval = 0;
      for j = 1:M
        Q = parameters(EA(1, j));
        v = l' * Q * l;
        if v > mval
          mval = v;
        end
      end
      x = l/realsqrt(mval);
      yy = [yy x];
    end
    yy = [T*ones(1, N); yy];


 [xx, tt] = get_goodcurves(rs);
 LL       = get_directions(rs);
 xx = xx{1};
 xi = [T; C*xx(:, end)];






 clear MM;

 for i = 1:199
	 cla;
   x0 = C*xx(:, i);
   X0 = x0 + Properties.getAbsTol()*ell_unitball(2);
   t0 = tt(i);
   L0 = [];
   for j = 1:M
	   L = LL{j};
	   L0 = [L0 L(:, i)];
   end

   rs = reach(s, X0, L0, [t0 T], o);
   plotByEa(rs); hold on;
   ell_plot(yy, 'r', 'LineWidth', 2);
   ell_plot(xi, 'ko');
   ell_plot([t0; x0], 'k*');
   ell_plot([tt(i:end); C*xx(:, i:end)], 'k');

   title(sprintf('Reach tube at time T = %d', t0));
  axis([0 T -40 40 -6 6]);

   hold off;

   MM(i) = getframe(h);
 end

 movie2avi(MM, 'internal_point.avi', 'QUALITY', 100);
   
