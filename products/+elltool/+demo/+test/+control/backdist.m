function backdist
startTime  = 5;
  w  = 2;
  aMat  = [0 1; -w 0];
  bMat  = eye(2);
  cMat  = eye(2);
  SUBounds  = ellipsoid([9 0; 0 2]);
  SVBounds  = ellipsoid([1 0; 0 2]);
  sys  = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds, cMat, SVBounds);
  
  x0EllObj = ellipsoid([10; 0], [25 0; 0 25]);
  dirsMat = [1 -1; 1 1; 0 1]';
  rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, [startTime 0], 'isRegEnabled',true, 'isJustCheck', false ,'regTol',1e-3);

  
end