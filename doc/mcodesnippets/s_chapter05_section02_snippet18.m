T = [0 100];  % represents 100 time steps from 1 to 100
dtrs = elltool.reach.ReachDiscrete(dtsys, X0, L, T);  % reach set for 100 time steps
dtrs2 = evolve(dtrs, 200);  % compute next 100 time steps

Tb = [50 0];  % backward time interval
dtbrs = elltool.reach.ReachDiscrete(dtsys, Y, L, Tb);  % backward reach set
dtbrs = refine(dtbrs, L1);  % refine the approximation
[EA, tt] = get_ea(dtbrs);  % get external approximating ellipsoids and time values
IA = get_ia(dtbrs)  % get internal approximating ellipsoids

% IA =
% 3x51 array of ellipsoids.
