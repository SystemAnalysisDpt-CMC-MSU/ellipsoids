Y = ellipsoid([8; 2], [4 1; 1 2]);  % target set in the form of ellipsoid
Tb = [10 5];  % backward time interval
brs = reach(sys, Y, L, Tb, options);  % backward reach set
brs = refine(brs, L1);  % refine the approximation
brs2 = evolve(brs, 0);  % further evolution in backward time from 5 to 0
