% define system 1
A1 = [-1/6 0 -1/3; 0 0 1/7; 1/2 -1/2 -1/2];
B1 = [1/6 1/3; 0 0; 0 0];
U1 = ellipsoid(eye(2));
s1 = linsys(A1, B1, U1);

% define system 2:
A2 = [-1/6 0 -1/3; 0 0 1/3; 1/6 -1/6 -1/3];
B2 = [1/6; 0; 0];
U2 = ellipsoid(1);
s2 = linsys(A2, B2, U2);

X0 = ellipsoid(0.01*eye(3));  % set of initial states
L0 = eye(3);  % 3 initial directions
TS = 2;  % time of switch
T = 3;  % terminating time

% compute the reach set:
rs1 = reach(s1, X0, L0, TS);  % reach set of the first system
% computation of the second reach set starts
% where the first left off
rs2 = evolve(rs1, T, s2);

% obtain projections onto (x1, x2) subspace:
BB = [1 0 0; 0 1 0]';  % (x1, x2) subspace basis
ps1 = projection(rs1, BB);
ps2 = projection(rs2, BB);

% plot the results:
subplot(2, 2, 1);
plot_ea(ps1, 'r');  % external apprx. of reach set 1 (red)
hold on;
plot_ia(ps1, 'g');  % internal apprx. of reach set 1 (green)
plot_ea(ps2, 'y');  % external apprx. of reach set 2 (yellow)
plot_ia(ps2, 'b');  % internal apprx. of reach set 2 (blue)

% plot the 3-dimensional reach set at time t = 3:
subplot(2, 2, 2);
plot_ea(cut(rs2, 3), 'y');
hold on;
plot_ia(cut(rs2, 3), 'b');
