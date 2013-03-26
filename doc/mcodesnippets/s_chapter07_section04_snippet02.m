%initial conditions:
X0 = [170; 180; 175; 170] + 10*ell_unitball(4);

L0 = [1; 0; 0; 0];  % single initial direction
N = 100;  % number of time steps

ffrs = elltool.reach.ReachDiscrete(s1, X0, L0, N);  % free-flow reach set
EA = ffrs.get_ea;  % 101x1 array of external ellipsoids
