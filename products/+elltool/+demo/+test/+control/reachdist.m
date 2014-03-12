function reachdist
  timeVec  = [0 5];
  w  = 1;
  aMat  = [0 1; -w 0];
  bMat  = eye(2);
  cVec = [0; 1];
  SUBounds.center = {'sin(t)'; 'cos(t)'};
  SUBounds.shape =  [9 0; 0 2];
  vBoundsEllObj  = ell_unitball(1);
  sys  = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds, cVec, vBoundsEllObj);
  x0EllObj = ellipsoid([10; 0], [1 0; 0 1]);
  dirsMat = [0 1; 1 -1; 1 2]';
  rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec,'isRegEnabled',true, 'isJustCheck', false ,'regTol',1e-3);

  rsObj.plotByEa();
  rsObj.plotByIa();

end