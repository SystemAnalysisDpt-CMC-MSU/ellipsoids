% target set in the form of ellipsoid
yEllObj = ellipsoid([8; 2], [4 1; 1 2]);
tbTimeVec = [10 5];  % backward time interval
% backward reach set
firstBrsObj = elltool.reach.ReachContinuous(sys, yEllObj, dirsMat,...
        tbTimeVec);  
firstBrsObj = firstBrsObj.refine(newDirsMat);  % refine the approximation
% further evolution in backward time from 5 to 0; 
secBrsObj = firstBrsObj.evolve(0) 