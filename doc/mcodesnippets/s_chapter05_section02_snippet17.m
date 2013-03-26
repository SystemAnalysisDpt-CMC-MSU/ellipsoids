Y = ellipsoid([8; 2], [4 1; 1 2]);  % target set in the form of ellipsoid
Tb = [10 5];  % backward time interval
brs = elltool.reach.ReachContinuous(sys, Y, L, Tb);  % backward reach set
brs = brs.refine(L1);  % refine the approximation
brs2 = brs.evolve(0);  % further evolution in backward time from 5 to 0