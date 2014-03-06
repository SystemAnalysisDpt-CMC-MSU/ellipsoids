
R = 4;
L = 0.5;
C = 0.1; 
firstAMat = [0 -1/C; 1/L -R/L];
firstBMat = [1/C 0; 0 1/L];
secondACMat = {'0' '-10'; '1/(2 + sin(t))' '-4/(2 + sin(t))'};
secondBCMat = {'10' '0'; '0' '1/(2 + sin(t))'};
firstSUBounds = ell_unitball(2);
secondSUBounds.center = {'1000/(t^2)'; 'sin(2*t)'};
secondSUBounds.shape = [4 -1; -1 1];

x0EllObj = 0.0001*ell_unitball(2);
timeVec  = [0 10];
newEndTime = 20;
dirsMat = [0 1; 1 1; 1 0; 1 -1]';
%L0 = [0 1; 1 0]';

firstSys  = elltool.linsys.LinSysContinuous(firstAMat, firstBMat, firstSUBounds);
secondSys  = elltool.linsys.LinSysContinuous(secondACMat, secondBCMat, secondSUBounds);
firstRsObj = elltool.reach.ReachContinuous(firstSys, x0EllObj, dirsMat, timeVec, 'isRegEnabled',true, 'isJustCheck', false ,'regTol',1e-4);
secondRsObj = firstRsObj.evolve(newEndTime, secondSys);

firstRsObj.plotByEa(); hold on;
firstRsObj.plotByIa(); hold on;
secondRsObj.plotByEa('r'); hold on;
secondRsObj.plotByIa('y'); hold on;
