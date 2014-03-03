import elltool.conf.Properties;

Properties.setNPlot2dPoints(1000)
aMat = {'0' '-10'; '1/(2 + sin(t))' '-4/(2 + sin(t))'};
bMat = {'10' '0'; '0' '1/(2 + sin(t))'};
%U = ell_unitball(2);
SUBounds = struct();
SUBounds.center = [0; 0];
SUBounds.shape = {'4 - sin(t)' '-1'; '-1' '1 + (cos(t))^2'};

x0EllObj = ell_unitball(2);
timeVec  = [0 20];
firstDirsMat = [1 1].';
secondDirsMat = [-1 1].';
thirdDirsMat = [0 1; 1 0].';
phi = 0:0.1:pi;
forthDirsMat = [cos(phi); sin(phi)];

firstSys  = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds);
firstRsObj = elltool.reach.ReachContinuous(firstSys, x0EllObj, firstDirsMat, timeVec);
secondRsObj = firstRsObj.refine(secondDirsMat);
thirdRsObj = secondRsObj.refine(thirdDirsMat);
forthRsObj = elltool.reach.ReachContinuous(firstSys, x0EllObj, forthDirsMat, timeVec);

