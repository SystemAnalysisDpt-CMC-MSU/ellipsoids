import elltool.conf.Properties;

thirdAMat = [0 1; -4 0];
thirdBMat = [1; 0];
thirdSUBounds = ell_unitball(1);
thirdSys = elltool.linsys.LinSysContinuous(thirdAMat, thirdBMat, thirdSUBounds);

secondAMat = {'0' '-10'; '1/(2 + sin(t))' '-4/(2 + sin(t))'};
secondBMat = {'10' '0'; '0' '1/(2 + sin(t))'};
secondSUBounds.center = [0; 0];
secondSUBounds.shape = {'4 - sin(t)' '-1'; '-1' '1 + (cos(t))^2'};
secondSys = elltool.linsys.LinSysContinuous(secondAMat, secondBMat, secondSUBounds);

firstAMat = [0 1; -4 0];
firstBMat = [1; 0];
firstSUBounds = ell_unitball(1);
% C1 = [0; 1];
% V1 = ellipsoid(0.05);
firstSys = elltool.linsys.LinSysContinuous(firstAMat, firstBMat, firstSUBounds);

x0EllObj = ell_unitball(2);

timeVec  = [0 5];
firstNewEndTime  = 10;
secondNewEndTime  = 15;

dirsMat  = [1 0; 2 1; 1 1; 1 2; 0 1; -1 2; -1 1; -2 1]';
firstRsObj = elltool.reach.ReachContinuous(firstSys, x0EllObj, dirsMat, timeVec, 'isRegEnabled',true, 'isJustCheck', false ,'regTol',1e-3);
secondRsObj = firstRsObj.evolve(firstNewEndTime, secondSys);
% thirdRsObj = secondRsObj.evolve(secondNewEndTime, thirdSys); % problem with regularization


