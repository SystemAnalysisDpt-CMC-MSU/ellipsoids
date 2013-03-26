T = [0 100];  % represents 100 time steps from 1 to 100
dtrs = elltool.reach.ReachDiscrete(dtsys, X0, L, T);  % reach set for 100 time steps
dtrs2 = dtrs.evolve(200);  % compute next 100 time steps

Tb = [50 0];  % backward time interval
dtbrs = elltool.reach.ReachDiscrete(dtsys, Y, L, Tb);  % backward reach set
dtbrs = dtbrs.refine(L1);  % refine the approximation
[EA, tt] = dtbrs.get_ea;  % get external approximating ellipsoids and time values
IA = dtbrs.get_ia  % get internal approximating ellipsoids

% IA =
% 3x51 array of ellipsoids.
