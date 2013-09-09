%%
%
% This demo presents functions for reachability analysis and verification of linear dynamical systems.
import elltool.conf.Properties;
cla;
axis([-4 4 -2 2]);
axis([-4 4 -2 2]);
grid off;
axis off;
text(-2, 0.5, 'REACHABILITY', 'FontSize', 16);
%%
%
% Consider simple RLC circuit with two bounded inputs - current i(t) and voltage v(t) sources, as shown in the picture.
% The equations of this circuit are based on Ohm's and Kirchoff's laws.
cla;
image(imread('circuit.jpg'));
axis off;
grid off;
R = 4;
R2 = 2;
L = 0.5;
L2 = 1;
C = 0.1;
%%
% Using capacitor voltage and inductor current as state variables, we arrive at the linear system shown above. Now we assign A and B matrix values, define control bounds P and declare a linear system object lsys:
%
% >> R = 4; L = 0.5; C = 0.1;
% >> A = [0 -1/C; 1/L -R/L];
% >> B = [1/C 0; 0 1/L];
% >> P = ell_unitball(2);
% >> lsys = elltool.linsys.LinSysFactory.create(A, B, P);
cla;
image(imread('circuitls.jpg'));
axis off;
grid off;
A = [0 -1/C; 1/L -R/L];
B = [1/C 0; 0 1/L];
P = ell_unitball(2);
A2 = [0 -1/C; 1/L2 -R2/L2];
B2 = [1/C 0; 0 1/L2];
X0 = 1e-5*ell_unitball(2);
T = 10;
L0 = [1 0; 0 1]';
s = elltool.linsys.LinSysFactory.create(A, B, P);
s2 = elltool.linsys.LinSysFactory.create(A2, B2, P);
%%
% We are ready to compute the reach set approximations of this system on some time interval, say T = [0, 10], for zero initial conditions and plot them:
%
% >> X0 = 0.00001*ell_unitball(2);
% >> T = 10;
% >> L0 = [1 0; 0 1]';
% >> rs = elltool.reach.ReachContinuous(lsys, X0, L0, T);
% >> rs.plotByEa(); hold on;
% >> rs.plotByIa();
% >> ylabel('V_C'); zlabel('i_L');
%
% On your screen you see the reach set evolving in time from 0 to 10 (reach tube). Its external and internal approximations are computed for two directions specified by matrix L0. Function 'plotEa' plots external (blue by default), and function 'plotIa' - internal (green by default) approximations.
rs = elltool.reach.ReachContinuous(s, X0, L0, [0 T],...
    'isRegEnabled', true, 'isJustCheck', false, 'regTol', 1e-4);
ell_plot([0; 0; 0], 'k.');
cla;
rs.plotByEa();
hold on;
rs.plotByIa();
ylabel('V_C');
zlabel('i_L');
%%
% Function 'evolve' computes the further evolution in time of already existing reach set. We computed the reach tube of our circuit for the time interval [0, 10]. Now, suppose, the dynamics of our system switched. For example, the parameters induction L and resistance R have changed:
%
% >> L2 = 1;
% >> R2 = 2;
% >> A2 = [0 -1/C; 1/L2 -R2/L2];
% >> B2 = [1/C 0; 0 1/L2];
% >> lsys2 = elltool.linsys.LinSysFactory.create(A2, B2, P);
%
% Now we continue computing the reach set for the time interval [10, 20] due to the new dynamics:
%
% >> rs2 = rs.evolve(20, s2);
% >> rs2.plotByEa('r'); hold on; rs2.plotByIa('y');
%
% plots external (red) and internal (yellow) approximations of the reach set of the system for the time interval [10, 20] and the new dynamics.
% Function 'evolve' can be used for computing the reach sets of switching systems.
%
rs2 = rs.evolve(20, s2);
rs2.plotByEa('color', [1 0 0], 'shade', 0.3);
rs2.plotByIa('color', [1 1 0], 'shade', 0.1);
%%
% To analyze the reachability of the system on some specific time segment within the computed time interval, use 'cut' function:
%
% >> ct = rs.cut([3 6]);
% >> ct.plotByEa(); hold on; ct.plotByIa();
%
% plots the reach tube approximations on the time interval [3, 6].
ct = rs.cut([3 6]);
cla;
ct.plotByEa();
hold on;
ct.plotByIa();
hold off;
ylabel('V_C');
zlabel('i_L');
%%
% Function 'cut' can also be used to obtain a snapshot of the reach set at given time within the computed time interval:
%
% >> ct = ct.cut(5);
% >> ct.plotByEa(); hold on; ct.plotByIa();
%
% plots the reach set approximations at time 5.
cla;
ct = ct.cut(5);
%
ct.plotByEa();
hold on;
ct.plotByIa();
xlabel('V_C');
ylabel('i_L');
%%
% Function 'intersect' is used to determine whether the reach set external or internal approximation intersects with given hyperplanes.
%
% >> HA = hyperplanes([1 0; 1 -2]', [4 -2]);
% >> ct.intersect(HA, 'e');
%
% ans =
%
%      1     1
%
% >> ct.intersect(HA, 'i');
%
% ans =
%
%      0     0
%
% Both hyperplanes (red) intersect the external approximation (blue) but do not intersect the internal approximation (green) of the reach set. It leaves the question whether the actual reach is intersected by these hyperplanes open.
HA = hyperplane([1 0; 1 -2]', [4 -2]);
plot(HA, 'r','lineWidth',2,'size',[3; 6.6],'center',[0 -2; 0 0]);
hold off;
%%
% Function 'intersect' works with ellipsoids as well as with hyperplanes:
%
% >> E1 = ellipsoid([2; -1], [4 -2; -2 2]);
% >> E2 = ell_unitball(2) - [6; -1];
% >> ct.intersect([E1 E2], 'i');
%
% ans =
%
%      1     0
%
% We see that ellipsoid E1 (red) intersects with the internal approximation (green) - hence, with the actual reach set. Ellipsoid E2 (black) does not intersect the internal approximation, but does it intersect the actual reach set?
%
% >> ct.intersect(E2, 'e');
%
% ans =
%
%      0
%
% Since ellipsoid E2 (black) does not intersect the external approximation (intersection of blue ellipsoids), it does not intersect the actual reach set.
% To work directly with ellipsoidal representations of external and internal approximations, bypassing the reach set object, use functions 'get_ea' and 'get_ia'. They return ellipsoidal arrays that can be treated by the functions of ellipsoidal calculus (see ell_demo1).
E1 = ellipsoid([2; -1], [4 -2; -2 2]);
E2 = ell_unitball(2) - [6; -1];
%
ct.plotByEa();
hold on;
ct.plotByIa();
plot(E1, 'r', E2, 'k', 'lineWidth',2);
hold off;
xlabel('V_C');
ylabel('i_L');
%%
% Suppose, induction L depends on t, for example, L = 2 + sin(t). Then, linear system object can be declared using symbolic matrices:
%
% >> A = {'0' '-10'; '1/(2 + sin(t))' '-4/(2 + sin(t))'};
% >> B = {'10' '0'; '0' '1/(2 + sin(t))'};
% >> s = elltool.linsys.LinSysFactory.create(A, B, P);
%
% Now the reach set of the system can be computed and plotted just as before:
%
% >> rs = elltool.reach.ReachContinuous(lsys, X0, L0, [0 4]);
% >> rs.plotByEa(); hold on; rs.plotByIa();
A = {'0' '-10'; '1/(2 + sin(t))' '-4/(2 + sin(t))'};
B = {'10' '0'; '0' '1/(2 + sin(t))'};
s = elltool.linsys.LinSysFactory.create(A, B, P);
rs = elltool.reach.ReachContinuous(s, X0, L0, [0 4],...
    'isRegEnabled', true, 'isJustCheck', false, 'regTol', 1e-4);
cla;
ell_plot([0; 0; 0], '.');
cla;
rs.plotByEa();
hold on;
rs.plotByIa();
ylabel('V_C');
zlabel('i_L');
%%
% Function 'get_goodcurves' is used to obtain the trajectories formed by points where the approximating ellipsoids touch the boundary of the reach set. Each such trajectory is defined by the value of initial direction. For this example we computed approximations for two directions.
%
% >> [XX, tt] = rs.get_goodcurves();
% >> x1 = XX{1};
% >> x2 = XX{2};
% >> plot3(tt, x1(1, :), x1(2, :), 'r', 'LineWidth', 2); hold on;
% >> plot3(tt, x2(1, :), x2(2, :), 'r', 'LineWidth', 2);
%
% plots the "good curve" trajectories (red) corresponding to the computed approximations.
[XX, tt] = rs.get_goodcurves();
x1 = [tt; XX{1}];
x2 = [tt; XX{2}];
ell_plot(x1, 'r', 'LineWidth', 2);
ell_plot(x2, 'r', 'LineWidth', 2);
hold off;
%%
% We can also compute the closed-loop reach set of the system in the presence of bounded disturbance. It is a guaranteed reach set. That is, no matter what the disturbance is (within its bounds), the system can reach one of those states. (Notice that such reach sets may be empty.)
%
% Let disturbance bounds depend on time:
%
% >> Q.center = {'2*cos(t)'};
% >> Q.shape = {'0.09*(sin(t))^2'};
% >> C = [1; 0];
%
% Now we declare the linear system object with disturbance:
%
% >> lsys = elltool.linsys.LinSysFactory.create(A, B, P, C, Q);
%
% Compute and plot the reach tube approximations:
%
% >> rs = elltool.reach.ReachContinuous(s, X0, L0, [0 4]);
% >> rs.plotByEa(); hold on; rs.plotByIa();
C = [1; 0];
Q.center = {'2*cos(t)'};
Q.shape = {'0.09*(sin(t))^2'};
s = elltool.linsys.LinSysFactory.create(A, B, P, C, Q);
rs = elltool.reach.ReachContinuous(s, X0, L0, [0 4],...
    'isRegEnabled', true, 'isJustCheck', false, 'regTol', 1e-2);
cla;
%rs.plotByEa();we do not reachability set hever and just plot the
%approximations because reach-set is a regularized one and regularization
%is different for every direction
rs.plotEa()
hold on;
rs.plotIa();
hold off;
ylabel('V_C');
zlabel('i_L');
%%
% Consider the spring-mass system displayed on the screen. It consists of two blocks, with masses m1 and m2, connected by three springs with spring constants k1 and k2 as shown. It is assumed that there is no friction between the blocks and the floor. The applied forces u1 and u2 must overcome the spring forces and remainder is used to accelerate the blocks.
%
% Thus, we arrive at equations shown in the picture.
cla;
image(imread('springmass.jpg'));
axis off;
grid off;
%%
% Defining x3 = dx1/dt and x4 = dx2/dt, we get the linear system shown in the picture.
%
% For k1 = 50, k2 = 47, m1 = 1.5 and m2 = 2, we can assign the matrix values:
%
% >> k1 = 50; k2 = 47; m1 = 1.5; m2 = 2;
% >> A = [0 0 1 0; 0 0 0 1; -(k1+k2)/m1 k2/m1 0 0; k2/m2 -(k1+k2)/m2 0 0];
% >> B = [0 0; 0 0; 1/m1 0; 0 1/m2];
%
% Specify control bounds:
%
% >> U = 5 * ell_unitball(2);
%
% And create linear system object:
%
% >> lsys = elltool.linsys.LinSysFactory.create(A, B, U);
cla;
image(imread('springmassls.jpg'));
axis off;
grid off;
k1 = 50;
k2 = 47;
m1 = 1.5;
m2 = 2;
A = [0 0 1 0; 0 0 0 1; -(k1+k2)/m1 k2/m1 0 0; k2/m2 -(k1+k2)/m2 0 0];
B = [0 0; 0 0; 1/m1 0; 0 1/m2];
U = 5*ell_unitball(2);
s = elltool.linsys.LinSysFactory.create(A, B, U);
T = 1;
X0 = 0.1*ell_unitball(4) + [2; 3; 0; 0];
L = [1 0 -1 1; 0 -1 1 1]';
%%
% Define the initial conditions and the end time:
%
% >> X0 = [2; 3; 0; 0] + 0.1*ell_unitball(4);
% >> T = 1;
%
% Now we are ready to compute the reach set approximations and plot the reach tube projected onto (x1, x2) subspace. We shall compute the approximations for two directions.
%
% >> L = [1 0 -1 0; 0 -1 1 1]';
% >> rs = elltool.reach.ReachContinuous(lsys, X0, L, T);
% >> ps = prs.projection([1 0 0 0; 0 1 0 0]');
% >> ps.plotByEa(); hold on; ps.plotByIa();
rs = elltool.reach.ReachContinuous(s, X0, L, [0 T],...
    'isRegEnabled', true, 'isJustCheck', false, 'regTol', 1e-5);
ps = rs.projection([1 0 0 0; 0 1 0 0]');
ell_plot([0; 0; 0], 'k.');
cla;
ps.plotByEa();
hold on;
ps.plotByIa();
%%
% Function 'get_center' is used to obtain the trajectory of the center of the reach set:
%
% >> [cnt, tt] = ps.get_center();
% >> plot3(tt, cnt(1, :), cnt(2, :), 'r', 'LineWidth', 2);
%
% plots the trajectory of reach set center (red).
[cnt, tt] = ps.get_center();
cnt = [tt; cnt];
ell_plot(cnt, 'r', 'LineWidth', 2);
hold off;
%%
% We can also compute backward reach set of the system:
%
% >> T = [1 0];
% >> brs = elltool.reach.ReachContinuous(lsys, X0, L, T);
% >> bps = brs.projection([1 0 0 0; 0 1 0 0]');
% >> bps.plotByEa(); hold on; bps.plotByIa();

% plots approximations of backward reach tube of the system for target point [2; 3] (used to be initial condition in the previous example, hence, is still denoted X0 in the code), terminating time 1 and initial time 0.
T = [1 0];
brs = elltool.reach.ReachContinuous(s, X0, L, T,...
    'isRegEnabled', true, 'isJustCheck', false, 'regTol', 1e-5);
bps = brs.projection([1 0 0 0; 0 1 0 0]');
cla;
bps.plotByEa(); hold on; bps.plotByIa(); hold off;
%%
% As an example of discrete-time linear system, we shall consider economic model entitled 'multiplier-accelerator', which is due to Samuelson (1939). It addresses the problem of income determination and business cycle.
% Denote:
%         C - consumption,
%         V - investment,
%         F - effective demand,
%         Y - national income,
%         R - interest rate,
%         k - time period.
%
% The 6-dimensional linear system is shown in the picture.
% Assign matrix values and define the linear system object (notice, it is discrete-time):
%
% >> A0 = [0.2 0 -0.4; 0 0 -0.6; 0 0.5 -1];
% >> A1 = [0.54 0 0.4; 0.06 0 0.6; 0.6 0 1];
% >> A  = [zeros(3, 3) eye(3); A0 A1];
% >> B1 = [-1.6 0.8; -2.4 0.2; -4 2];
% >> B  = [zeros(3, 2); B1];
% >> U.center = {'(k+7)/100'; '2'};
% >> U.shape  = [0.02 0; 0 1];
% >> lsys = elltool.linsys.LinSysFactory.create(A, B, U, [], [], [], [], 'd');
cla;
image(imread('econ.jpg'));
axis off;
grid off;
A0 = [0.2 0 -0.4; 0 0 -0.6; 0 0.5 -1];
A1 = [0.54 0 0.4; 0.06 0 0.6; 0.6 0 1];
A  = [zeros(3, 3) eye(3); A0 A1];
B1 = [-1.6 0.8; -2.4 0.2; -4 2];
B = [zeros(3, 2); B1];
clear U;
U.center = {'(k+7)/100'; '2'};
U.shape = [0.02 0; 0 1];
X0 = ellipsoid([1; 0.5; -0.5; 1.10; 0.55; 0], eye(6));
lsys = elltool.linsys.LinSysFactory.create(A, B, U, [], [], 'd');
L0 = [1 0 0 0 0 0; 0 1 0 0 0 0; 0 0 1 0 0 1; 0 1 0 1 1 0; 0 0 -1 1 0 1; 0 0 0 -1 1 1]';
%%
% Now we compute the reach set for time interval [1 4] and plot the projection onto (V[k], Y[k]) subspace:
%
% >> X0 = ellipsoid([1; 0.5; -0.5; 1.10; 0.55; 0], eye(6));
% >> L0 = [1 0 0 0 0 0; 0 1 0 0 0 0; 0 0 1 0 0 1; 0 1 0 1 1 0; 0 0 -1 1 0 1; 0 0 0 -1 1 1]';
% >> N  = 4;
% >> rs = elltool.reach.ReachDiscrete(lsys, X0, L0, N);
% >> BB = [0 0 0 0 1 0; 0 0 0 0 0 1]';
% >> ps = rs.projection(BB);
% >> ps.plotByEa(); hold on; ps.plotByIa();
%
% Forward reach sets can be computed for singular discrete-time systems as well. Backward reach sets, on the other hand, can be computed only for nonsingular discrete-time systems.
timeLimsVec = [1 4];
rs = elltool.reach.ReachDiscrete(lsys, X0, L0, timeLimsVec);
BB = [0 0 0 0 1 0; 0 0 0 0 0 1]';
ps = rs.projection(BB);
plotByEa(ps);
hold on;
plotByIa(ps);
hold off;
ylabel('V[k]');
zlabel('Y[k]');
%%
% For more information, type
%
% >> help elltool.linsys.LinSys
%
% and
%
% >> help elltool.reach.ReachContinuous
% >> help elltool.reach.ReachDiscrete
%
% or look into elltool.reach.IReach
%
cla;
axis([-4 4 -2 2]);
title('');
axis([-4 4 -2 2]);
grid off;
axis off;
text(-1, 0.5, 'THE END', 'FontSize', 16);
