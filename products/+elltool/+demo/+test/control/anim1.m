import elltool.conf.Properties;

Properties.setNPlot2dPoints(1000)
aCMat = {'0' '-10'; '1/(2 + sin(t))' '-4/(2 + sin(t))'};
bCMat = {'10' '0'; '0' '1/(2 + sin(t))'};
%U = ell_unitball(2);
SUBounds = struct();
SUBounds.center = [0; 0];
SUBounds.shape = {'4 - sin(t)' '-1'; '-1' '1 + (cos(t))^2'};

x0EllObj = ell_unitball(2);
timeVec  = [0 20];
firstDirVec = [1 1].';
secondDirVec = [-1 1].';
thirdDirsMat = [0 1; 1 0].';
phi = 0:0.1:pi;
forthDirsMat = [cos(phi); sin(phi)];

firstSys  = elltool.linsys.LinSysContinuous(aCMat, bCMat, SUBounds);
firstRsObj = elltool.reach.ReachContinuous(firstSys, x0EllObj, firstDirVec, timeVec);
secondRsObj = firstRsObj.refine(secondDirVec);
thirdRsObj = secondRsObj.refine(thirdDirsMat);
forthRsObj = elltool.reach.ReachContinuous(firstSys, x0EllObj, forthDirsMat, timeVec);

