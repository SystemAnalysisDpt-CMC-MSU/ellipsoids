Ad = [0 1; -1 -0.5]; Bd = [0; 1];  % matrices A and B
Ud  = ellipsoid(1);  % control bounds: unit ball in R
dtsys = linsys(Ad, Bd, Ud, [], [], [], [], 'd');  % discrete-time system
