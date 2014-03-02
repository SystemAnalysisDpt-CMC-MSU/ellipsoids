
  firstAMat = {'sin(0.3*t)' '-0.22' '0'; '0' '-1' '0'; '-0.5' '1' 'cos(0.2*t)'};
  secondAMat = [0 0 1; 0 0 0; -4 0 0];
  firstBMat = [0 1 1; 1 1 0; 1 0 1];
  secondBMat = [1 0; 0 0; 0 1];
  firstSUBounds = ellipsoid([1 0 0; 0 2 0; 0 0 2]);
  secondSUBounds.center = [0; 0];
  secondSUBounds.shape = {'2 - sin(2*t)' '0'; '0' '2- cos(3*t)'};
  timeVec  = [0 2];
  dirsMat = [1 0 0; 0 0 1;0 1 1;1 -1 1; 1 0 1; 1 1 0]';
  x0EllObj = ell_unitball(3);

  firstSys = elltool.linsys.LinSysContinuous(firstAMat, firstBMat, firstSUBounds);
  secondSys = elltool.linsys.LinSysContinuous(secondAMat, secondBMat, secondSUBounds);
  firstRsObj = elltool.reach.ReachContinuous(firstSys, x0EllObj, dirsMat, timeVec, 'isRegEnabled',true, 'isJustCheck', false ,'regTol',1e-3);
  secondRsObj = evolve(firstRsObj, 5, secondSys);
