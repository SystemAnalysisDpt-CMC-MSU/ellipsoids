timeVec = [0 100];  % represents 100 time steps from 1 to 100
% reach set for 100 time steps
secDtrsObj = elltool.reach.ReachDiscrete(dtsys, x0EllObj, dirsMat, timeVec); 
secDtrsObj = secDtrsObj.evolve(200);  % compute next 100 time steps

tbTimeVec = [50 0];  % backward time interval
% backward reach set
dtbrsObj = elltool.reach.ReachDiscrete(dtsys, yEllObj, dirsMat, tbTimeVec);  
dtbrsObj = dtbrsObj.refine(newDirsMat);  % refine the approximation
% get external approximating ellipsoids and time values
[externallEllMat, timeVec] = dtbrsObj.get_ea();
% get internal approximating ellipsoids
internalEllMat = dtbrsObj.get_ia()

% internalEllMat =
% Array of ellipsoids with dimensionality 3x51
