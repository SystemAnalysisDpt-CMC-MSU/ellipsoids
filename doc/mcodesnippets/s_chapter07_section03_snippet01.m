% define system 1
A1 = [-1/6 0 -1/3; 0 0 1/7; 1/2 -1/2 -1/2];
B1 = [1/6 1/3; 0 0; 0 0];
U1 = ellipsoid(eye(2));
s1 = elltool.linsys.LinSys(A1, B1, U1);

% define system 2:
A2 = [-1/6 0 -1/3; 0 0 1/3; 1/6 -1/6 -1/3];
B2 = [1/6; 0; 0];
U2 = ellipsoid(1);
s2 = elltool.linsys.LinSys(A2, B2, U2);

X0 = ellipsoid(0.01*eye(3));  % set of initial states
L0 = eye(3);  % 3 initial directions
TS = 2;  % time of switch
T = 3;  % terminating time

% compute the reach set:
rs1 = elltool.reach.ReachContinuous(s1, X0, L0, [0 TS]);  % reach set of the first system
% computation of the second reach set starts
% where the first left off
rs2 = rs1.evolve(T, s2);

% obtain projections onto (x1, x2) subspace:
BB = [1 0 0; 0 1 0]';  % (x1, x2) subspace basis
ps1 = rs1.projection(BB);
ps2 = rs2.projection(BB);

% plot the results:
subplot(2, 2, 1);
ps1.plot_ea('r');  % external apprx. of reach set 1 (red)
hold on;
ps1.plot_ia('g');  % internal apprx. of reach set 1 (green)
ps2.plot_ea('y');  % external apprx. of reach set 2 (yellow)
ps2.plot_ia('b');  % internal apprx. of reach set 2 (blue)

% plot the 3-dimensional reach set at time t = 3:
subplot(2, 2, 2);
rs2 = rs2.cut(3)
rs2.plot_ea('y');
hold on;
rs2.plot_ia('b');
