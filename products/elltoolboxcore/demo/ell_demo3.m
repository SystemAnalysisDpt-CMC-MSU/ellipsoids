function slide = ell_demo3
%
%    Reachability Demo.
%

%
% Author:
% -------
%
%    Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
%

  import elltool.conf.Properties;

 
  verbose                = Properties.getIsVerbose();
  plot2d_grid            = Properties.getNPlot2dPoints();
  Properties.setIsVerbose(false);
  Properties.setNPlot2dPoints(1000);
  
 if nargout < 1
    playshow ell_demo3;
    Properties.setIsVerbose(verbose);
    Properties.setNPlot2dPoints(plot2d_grid);
  else
    NN = 1;
    slide(NN).code = {
      'import elltool.conf.Properties;',
      'cla; axis([-4 4 -2 2]);',
      'axis([-4 4 -2 2]); grid off; axis off;',
      'text(-2, 0.5, ''REACHABILITY'', ''FontSize'', 16);'
    };
    slide(NN).text = {
      '',
      'This demo presents functions for reachability analysis and verification of linear dynamical systems.'
    };


    NN = NN + 1;
    slide(NN).code = {
      'cla; image(imread(''circuit.jpg'')); axis off; grid off;',
      'R = 4; R2 = 2; L = 0.5; L2 = 1; C = 0.1;'
    };
    slide(NN).text = {
    '',
      'Consider simple RLC circuit with two bounded inputs - current i(t) and voltage v(t) sources, as shown in the picture.',
      'The equations of this circuit are based on Ohm''s and Kirchoff''s laws.'
    };


    NN = NN + 1;
    slide(NN).code = {
      'cla; image(imread(''circuitls.jpg'')); axis off; grid off;',
      'A = [0 -1/C; 1/L -R/L]; B = [1/C 0; 0 1/L]; CB = ell_unitball(2);',
      'A2 = [0 -1/C; 1/L2 -R2/L2]; B2 = [1/C 0; 0 1/L2];',
      'X0 = 0.00001*ell_unitball(2); T = 10; o.save_all = 1; L0 = [1 0; 0 1]'';',
      's = linsys(A, B, CB); s2 = linsys(A2, B2, CB);'
    };
    slide(NN).text = {
      'Using capacitor voltage and inductor current as state variables, we arrive at the linear system shown above. Now we assign A and B matrix values, define control bounds CB and declare a linear system object lsys:',
      '',
      '>> R = 4; L = 0.5; C = 0.1;',
      '>> A = [0 -1/C; 1/L -R/L];',
      '>> B = [1/C 0; 0 1/L];',
      '>> CB = ell_unitball(2);',
      '>> lsys = linsys(A, B, CB);'
    };


    NN = NN + 1;
    slide(NN).code = {
      'o.save_all = 1; rs = reach(s, X0, L0, T, o);',
      'ell_plot([0; 0; 0], ''k.''); cla;',
      'plot_ea(rs); hold on; plot_ia(rs);',
      'ylabel(''V_C''); zlabel(''i_L'');'
    };
    slide(NN).text = {
      'We are ready to compute the reach set approximations of this system on some time interval, say T = [0, 10], for zero initial conditions and plot them:',
      '',
      '>> X0 = 0.00001*ell_unitball(2);'
      '>> T = 10;',
      '>> options.save_all = 1;',
      '>> L0 = [1 0; 0 1]'';',
      '>> rs = reach(lsys, X0, L0, T);',
      '>> plot_ea(rs); hold on;',
      '>> plot_ia(rs);',
      '>> ylabel(''V_C''); zlabel(''i_L'');'
      '',
      'Option ''save_all'' set to 1 (by default, it is 0) indicates that the whole intermediate computation information should be saved in the reach set object. This information can be later used for refinement of the reach set approximation.',
      'On your screen you see the reach set evolving in time from 0 to 10 (reach tube). Its external and internal approximations are computed for two directions specified by matrix L0. Function ''plot_ea'' plots external (blue by default), and function ''plot_ia'' - internal (green by default) approximations.'
    };


    NN = NN + 1;
    slide(NN).code = {
      'rs2 = evolve(rs, 20, s2); plot_ea(rs2, ''r''); plot_ia(rs2, ''y'');'
    };
    slide(NN).text = {
      'Function ''evolve'' computes the further evolution in time of already existing reach set. We computed the reach tube of our circuit for the time interval [0, 10]. Now, suppose, the dynamics of our system switched. For example, the parameters induction L and resistance R have changed:',
      '',
      '>> L2 = 1;',
      '>> R2 = 2;',
      '>> A2 = [0 -1/C; 1/L2 -R2/L2];',
      '>> B2 = [1/C 0; 0 1/L2];',
      '>> lsys2 = linsys(A2, B2, CB);',
      '',
      'Now we continue computing the reach set for the time interval [10, 20] due to the new dynamics:',
      '',
      '>> rs2 = evolve(rs, 20, s2); plot_ea(rs2, ''r''); plot_ia(rs2, ''y'');',
      '>> plot_ea(rs2, ''r''); hold on; plot_ia(rs2, ''y'');',
      '',
      'plots external (red) and internal (yellow) approximations of the reach set of the system for the time interval [10, 20] and the new dynamics.'
      'Function ''evolve'' can be used for computing the reach sets of switching systems.'
    };


    NN = NN + 1;
    slide(NN).code = {
      'ct = cut(rs, [3 5]);',
      'cla;',
      'plot_ea(ct); hold on; plot_ia(ct); hold off',
      'ylabel(''V_C''); zlabel(''i_L'');'
    };
    slide(NN).text = {
      'To analyze the reachability of the system on some specific time segment within the computed time interval, use ''cut'' function:',
      '',
      '>> ct = cut(rs, [3 5]);',
      '>> plot_ea(ct); hold on; plot_ia(ct);',
      '',
      'plots the reach tube approximations on the time interval [3, 5].'
    };


    NN = NN + 1;
    slide(NN).code = {
      'import elltool.conf.Properties; Properties.setNPlot2dPoints(800);',
      'cla; ct = cut(ct, 5); plot_ea(ct); hold on; plot_ia(ct);',
      'xlabel(''V_C''); ylabel(''i_L'');'
    };
    slide(NN).text = {
      'Function ''cut'' can also be used to obtain a snapshot of the reach set at given time within the computed time interval:',
      '',
      '>> ct = cut(ct, 5);',
      '>> plot_ea(ct); hold on; plot_ia(ct);',
      '',
      'plots the reach set approximations at time 5.'
    };


    NN = NN + 1;
    slide(NN).code = {
      'HA = hyperplane([1 0; 1 -2]'', [4 -2]);',
      'o.width = 2; o.size = [3 6.6]; o.center = [0 -2; 0 0];',
      'plot(HA, ''r'', o); hold off;'
    };
    slide(NN).text = {
      'Function ''intersect'' is used to determine whether the reach set external or internal approximation intersects with given hyperplanes.',
      '',
      '>> HA = hyperplanes([1 0; 1 -2]'', [4 -2]);',
      '>> intersect(ct, HA, ''e'');',
      '',
      'ans =',
      '',
      '     1     1',
      '',
      '>> intersect(ct, HA, ''i'');'
      '',
      'ans =',
      '',
      '     0     0',
      '',
      'Both hyperplanes (red) intersect the external approximation (blue) but do not intersect the internal approximation (green) of the reach set. It leaves the question whether the actual reach is intersected by these hyperplanes open.' 
    };


    NN = NN + 1;
    slide(NN).code = {
      'ct = cut(refine(rs, [1 1; 1 -1]''), 5);',
      'plot_ea(ct); hold on; plot_ia(ct); plot(HA, ''r'', o); hold off;',
      'xlabel(''V_C''); ylabel(''i_L'');'
    };
    slide(NN).text = {
      'In case when it cannot be determined if the actual reach set intersects with given hyperplanes, use ''refine'' function to improve the quality of approximations. This function computes external and internal ellipsoidal tubes for additional directions.',
      '',
      '>> LL = [1 1; 1 -1]'';',
      '>> rrs = refine(rs, LL);',
      '>> ct = cut(rrs, 5);',
      '>> intersect(ct, HA, ''i'');',
      '',
      'ans =',
      '',
      '     1     1',
      '',
      'After refinement, we see that the hyperplanes (red) intersect the internal approximation of the reach set (green). Hence, these hyperplanes intersect the actual reach set at time 5.'
    };


    NN = NN + 1;
    slide(NN).code = {
      'E1 = ellipsoid([2; -1], [4 -2; -2 2]);',
      'E2 = ell_unitball(2) - [6; -1];',
      'plot_ea(ct); hold on; plot_ia(ct); plot(E1, ''r'', E2, ''k'', o); hold off;',
      'xlabel(''V_C''); ylabel(''i_L'');'
    };
    slide(NN).text = {
      'Function ''intersect'' works with ellipsoids as well as with hyperplanes:',
      '',
      '>> E1 = ellipsoid([2; -1], [4 -2; -2 2]);',
      '>> E2 = ell_unitball(2) - [6; -1];',
      '>> intersect(ct, [E1 E2], ''i'');',
      '',
      'ans =',
      '',
      '     1     0',
      '',
      'We see that ellipsoid E1 (red) intersects with the internal approximation (green) - hence, with the actual reach set. Ellipsoid E2 (black) does not intersect the internal approximation, but does it intersect the actual reach set?',
      '',
      '>> intersect(ct, E2, ''e'');',
      '',
      'ans =',
      '',
      '     0',
      '',
      'Since ellipsoid E2 (black) does not intersect the external approximation (intersection of blue ellipsoids), it does not intersect the actual reach set.'
      'To work directly with ellipsoidal representations of external and internal approximations, bypassing the reach set object, use functions ''get_ea'' and ''get_ia''. They return ellipsoidal arrays that can be treated by the functions of ellipsoidal calculus (see ell_demo1).'
    };


    NN = NN + 1;
    slide(NN).code = {
      'import elltool.conf.Properties; Properties.setNPlot2dPoints(200);',
      'A = {''0'' ''-10''; ''1/(2 + sin(t))'' ''-4/(2 + sin(t))''};',
      'B = {''10'' ''0''; ''0'' ''1/(2 + sin(t))''};',
      's = linsys(A, B, CB); rs = reach(s, X0, L0, 10);',
      'cla; ell_plot([0; 0; 0], ''.'');'
      'cla; plot_ea(rs); hold on; plot_ia(rs);',
      'ylabel(''V_C''); zlabel(''i_L'');'
    };
    slide(NN).text = {
      'Suppose, induction L depends on t, for example, L = 2 + sin(t). Then, linear system object can be declared using symbolic matrices:',
      '',
      '>> A = {''0'' ''-10''; ''1/(2 + sin(t))'' ''-4/(2 + sin(t))''};',
      '>> B = {''10'' ''0''; ''0'' ''1/(2 + sin(t))''};',
      '>> s = linsys(A, B, CB);',
      '',
      'Now the reach set of the system can be computed and plotted just as before:',
      '',
      '>> rs = reach(lsys, X0, L0, 10);',
      '>> plot_ea(rs); hold on; plot_ia(rs);'
    };


    NN = NN + 1;
    slide(NN).code = {
      '[XX, tt] = get_goodcurves(rs);',
      'x1 = [tt; XX{1}]; x2 = [tt; XX{2}];',
      'ell_plot(x1, ''r'', ''LineWidth'', 2);',
      'ell_plot(x2, ''r'', ''LineWidth'', 2); hold off;'
    };
    slide(NN).text = {
      'Function ''get_goodcurves'' is used to obtain the trajectories formed by points where the approximating ellipsoids touch the boundary of the reach set. Each such trajectory is defined by the value of initial direction. For this example we computed approximations for two directions.',
      '',
      '>> [XX, tt] = get_goodcurves(rs);',
      '>> x1 = XX{1};',
      '>> x2 = XX{2};',
      '>> plot3(tt, x1(1, :), x1(2, :), ''r'', ''LineWidth'', 2); hold on;',
      '>> plot3(tt, x2(1, :), x2(2, :), ''r'', ''LineWidth'', 2);',
      '',
      'plots the "good curve" trajectories (red) corresponding to the computed approximations.'
    };


    NN = NN + 1;
    slide(NN).code = {
      'G = [1; 0]; V.center = {''2*cos(t)''}; V.shape = {''0.09*(sin(t))^2''};',
      's = linsys(A, B, CB, G, V);',
      'rs = reach(s, X0, L0, 10);',
      'cla; plot_ea(rs); hold on; plot_ia(rs); hold off;',
      'ylabel(''V_C''); zlabel(''i_L'');'
    };
    slide(NN).text = {
      'We can also compute the closed-loop reach set of the system in the presence of bounded disturbance. It is a guaranteed reach set. That is, no matter what the disturbance is (within its bounds), the system can reach one of those states. (Notice that such reach sets may be empty.)',
      '',
      'Let disturbance bounds depend on time:',
      '',
      '>> DB.center = {''2*cos(t)''};',
      '>> DB.shape = {''0.09*(sin(t))^2''};',
      '>> G = [1; 0];',
      '',
      'Now we declare the linear system object with disturbance:',
      '',
      '>> lsys = linsys(A, B, CB, G, DB);',
      '',
      'Compute and plot the reach tube approximations:',
      '',
      '>> rs = reach(s, X0, L0, 10);',
      '>> plot_ea(rs); hold on; plot_ia(rs);'
    };


    NN = NN + 1;
    slide(NN).code = {
      'cla; image(imread(''springmass.jpg'')); axis off; grid off;'
    };
    slide(NN).text = {
      'Consider the spring-mass system displayed on the screen. It consists of two blocks, with masses m1 and m2, connected by three springs with spring constants k1 and k2 as shown. It is assumed that there is no friction between the blocks and the floor. The applied forces u1 and u2 must overcome the spring forces and remainder is used to accelerate the blocks.',
      '',
      'Thus, we arrive at equations shown in the picture.'
    };


    NN = NN + 1;
    slide(NN).code = {
      'cla; image(imread(''springmassls.jpg'')); axis off; grid off;',
      'k1 = 50; k2 = 47; m1 = 1.5; m2 = 2;',
      'A = [0 0 1 0; 0 0 0 1; -(k1+k2)/m1 k2/m1 0 0; k2/m2 -(k1+k2)/m2 0 0];',
      'B = [0 0; 0 0; 1/m1 0; 0 1/m2];'
      'U = 5*ell_unitball(2);',
      's = linsys(A, B, U);',
      'T = 5; X0 = 0.0001*ell_unitball(4) + [2; 3; 0; 0];',
      'L = [1 0 -1 1; 0 -1 1 1]'';',
    };
    slide(NN).text = {
      'Defining x3 = dx1/dt and x4 = dx2/dt, we get the linear system shown in the picture.',
      '',
      'For k1 = 50, k2 = 47, m1 = 1.5 and m2 = 2, we can assign the matrix values:',
      '',
      '>> k1 = 50; k2 = 47; m1 = 1.5; m2 = 2;',
      '>> A = [0 0 1 0; 0 0 0 1; -(k1+k2)/m1 k2/m1 0 0; k2/m2 -(k1+k2)/m2 0 0];',
      '>> B = [0 0; 0 0; 1/m1 0; 0 1/m2];'
      '',
      'Specify control bounds:',
      '',
      '>> U = 5 * ell_unitball(2);',
      '',
      'And create linear system object:',
      '',
      '>> lsys = linsys(A, B, U);'
    };


    NN = NN + 1;
    slide(NN).code = {
      'rs = reach(s, X0, L, T);'
      'ps = projection(rs, [1 0 0 0; 0 1 0 0]'');',
      'ell_plot([0; 0; 0], ''k.''); cla;',
      'plot_ea(ps); hold on; plot_ia(ps);'
    };
    slide(NN).text = {
      'Define the initial conditions and the end time:',
      '',
      '>> X0 = [2; 3; 0; 0] + 0.00001*ell_unitball(4);',
      '>> T = 5;',
      '',
      'Now we are ready to compute the reach set approximations and plot the reach tube projected onto (x1, x2) subspace. We shall compute the approximations for two directions.',
      '',
      '>> L = [1 0 -1 0; 0 -1 1 1]'';',
      '>> rs = reach(lsys, X0, L, T);'
      '>> ps = projection(rs, [1 0 0 0; 0 1 0 0]'');',
      '>> plot_ea(ps); hold on; plot_ia(ps);'
    };


    NN = NN + 1;
    slide(NN).code = {
      '[cnt, tt] = get_center(ps); cnt = [tt; cnt];',
      'ell_plot(cnt, ''r'', ''LineWidth'', 2); hold off;'
    };
    slide(NN).text = {
      'Function ''get_center'' is used to obtain the trajectory of the center of the reach set:',
      '',
      '>> [cnt, tt] = get_center(ps);',
      '>> plot3(tt, cnt(1, :), cnt(2, :), ''r'', ''LineWidth'', 2);',
      '',
      'plots the trajectory of reach set center (red).'
    };


    NN = NN + 1;
    slide(NN).code = {
      'T = [5 0]; rs = reach(s, X0, L, T);'
      'ps = projection(rs, [1 0 0 0; 0 1 0 0]'');',
      'cla;',
      'plot_ea(ps); hold on; plot_ia(ps); hold off;'
    };
    slide(NN).text = {
      'We can also compute backward reach set of the system:',
      '',
      '>> T = [5 0];',
      '>> brs = reach(lsys, X0, L, T);',
      '>> bps = projection(brs, [1 0 0 0; 0 1 0 0]'');',
      '>> plot_ea(bps); hold on; plot_ia(bps);',
      '',
      'plots approximations of backward reach tube of the system for target point [2; 3] (used to be initial condition in the previous example, hence, is still denoted X0 in the code), terminating time 5 and initial time 0.'
    };


    NN = NN + 1;
    slide(NN).code = {
      'cla; image(imread(''econ.jpg'')); axis off; grid off;',
      'A0 = [0.2 0 -0.4; 0 0 -0.6; 0 0.5 -1];',
      'A1 = [0.54 0 0.4; 0.06 0 0.6; 0.6 0 1];',
      'A  = [zeros(3, 3) eye(3); A0 A1];',
      'B1 = [-1.6 0.8; -2.4 0.2; -4 2]; B = [zeros(3, 2); B1];',
      'clear U;',
      'U.center = {''(k+7)/100''; ''2''}; U.shape = [0.02 0; 0 1];',
      'X0 = ellipsoid([1; 0.5; -0.5; 1.10; 0.55; 0], eye(6));',
      'lsys = linsys(A, B, U, [], [], [], [], ''d'');',
      'L0 = [1 0 0 0 0 0; 0 1 0 0 0 0; 0 0 1 0 0 1; 0 1 0 1 1 0; 0 0 -1 1 0 1; 0 0 0 -1 1 1]'';'
    };
    slide(NN).text = {
      'As an example of discrete-time linear system, we shall consider economic model entitled ''multiplier-accelerator'', which is due to Samuelson (1939). It addresses the problem of income determination and business cycle.',
      'Denote:',
      '        C - consumption,',
      '        V - investment,',
      '        F - effective demand,',
      '        Y - national income,',
      '        R - interest rate,',
      '        k - time period.',
      '',
      'The 6-dimensional linear system is shown in the picture.',
      'Assign matrix values and define the linear system object (notice, it is discrete-time):',
      '',
      '>> A0 = [0.2 0 -0.4; 0 0 -0.6; 0 0.5 -1];',
      '>> A1 = [0.54 0 0.4; 0.06 0 0.6; 0.6 0 1];',
      '>> A  = [zeros(3, 3) eye(3); A0 A1];',
      '>> B1 = [-1.6 0.8; -2.4 0.2; -4 2];',
      '>> B  = [zeros(3, 2); B1];',
      '>> U.center = {''(k+7)/100''; ''2''};',
      '>> U.shape  = [0.02 0; 0 1];',
      '>> lsys = linsys(A, B, U, [], [], [], [], ''d'');'
    };


    NN = NN + 1;
    slide(NN).code = {
      'N  = 4;',
      'rs = reach(lsys, X0, L0, N);'
      'BB = [0 0 0 0 1 0; 0 0 0 0 0 1]'';',
      'ps = projection(rs, BB);',
      'plot_ea(ps); hold on; plot_ia(ps); hold off;',
      'ylabel(''V[k]''); zlabel(''Y[k]'');'
    };
    slide(NN).text = {
      'Now we compute the reach set for N = 4 time steps and plot the projection onto (V[k], Y[k]) subspace:',
      '',
      '>> X0 = ellipsoid([1; 0.5; -0.5; 1.10; 0.55; 0], eye(6));',
      '>> L0 = [1 0 0 0 0 0; 0 1 0 0 0 0; 0 0 1 0 0 1; 0 1 0 1 1 0; 0 0 -1 1 0 1; 0 0 0 -1 1 1]'';'
      '>> N  = 4;',
      '>> rs = reach(lsys, X0, L0, N);'
      '>> BB = [0 0 0 0 1 0; 0 0 0 0 0 1]'';',
      '>> ps = projection(rs, BB);',
      '>> plot_ea(ps); hold on; plot_ia(ps);',
      '',
      'Forward reach sets can be computed for singular discrete-time systems as well. Backward reach sets, on the other hand, can be computed only for nonsingular discrete-time systems.'
    };


    NN = NN + 1;
    slide(NN).code = {
      'cla; axis([-4 4 -2 2]);',
      'title('''');',
      'axis([-4 4 -2 2]); grid off; axis off;',
      'text(-1, 0.5, ''THE END'', ''FontSize'', 16);'
    };
    slide(NN).text = {
      'For more information, type',
      '',
      '>> help linsys',
      '',
      'and',
      '',
      '>> help reach/contents',
    };
  end

  return;
