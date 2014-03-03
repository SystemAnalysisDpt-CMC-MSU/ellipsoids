import elltool.conf.Properties;

  C = 1;
  firstAMat = {'sin(3*t)' '-0.22' '0'; '0' '-1' '0'; '-0.5' '1' 'cos(0.2*t)'};
  firstBMat = [0 1 0; 1 0 0;0 0 1];
  firstSUBounds.center = [0; 0; 0];
  firstSUBounds.shape = {'2 - sin(2*t)' '0' '0'; '0' '2- cos(3*t)' '0'; '0' '0' '1'};
  timeVec  = [0 3];
  dirsMat = [1 0 0; 0 0 1;0 1 1;1 -1 1; 1 0 1; 1 1 0]';
  x0EllObj = [4 -2 5]' +Properties.getAbsTol()*ell_unitball(3);

  firstSys = elltool.linsys.LinSysContinuous(firstAMat, firstBMat, firstSUBounds);
  firstRsObj = elltool.reach.ReachContinuous(firstSys, x0EllObj, dirsMat, timeVec, 'isRegEnabled',true, 'isJustCheck', false ,'regTol',1e-3);

  [xx, tt] = firstRsObj.get_goodcurves();
  xx = xx{1};


