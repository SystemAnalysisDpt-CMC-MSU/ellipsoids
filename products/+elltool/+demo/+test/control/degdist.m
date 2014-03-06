  timeVec  = [0 5];
  w  = 2;
  aMat  = [0 1; -w 0];
  bMat  = eye(2);
  cMat  = eye(2);
  SUBounds  = ellipsoid([0.9 0; 0 0.1]);
  SVBounds  = ellipsoid([36 0; 0 49]);
  sys  = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds, cMat, SVBounds);
  
  x0EllObj = ellipsoid([10; 0], [0.5 0; 0 0.5]);
%   dirsMat = [1 -1; 1 1; 0 1; 1 0]';
  dirsMat = [1 1; 1 -1]';
  rsObj = elltool.reach.ReachContinuous(s, x0EllObj, dirsMat, timeVec, 'isRegEnabled',true, 'isJustCheck', false ,'regTol',1e-3);
