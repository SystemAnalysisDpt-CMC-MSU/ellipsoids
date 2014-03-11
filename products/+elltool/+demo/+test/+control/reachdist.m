function reachdist
  timeVec  = [0 5];
  w  = 1;
  aMat  = [0 1; -w 0];
  %A  = {'0' '1'; '-1.5+cos(2*t)' '0'};
  bMat  = eye(2);
%   cMat  = eye(2);
  cMVec = [0; 1];
  SUBounds.center = {'sin(t)'; 'cos(t)'};
  SUBounds.shape =  [9 0; 0 2];
%   SVBounds  = ellipsoid([1 -1; -1 3]);
  SVBounds  = ell_unitball(1);
  sys  = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds, cMVec, SVBounds);
  %sys  = linsys(aMat, bMat, SUBounds);
  
  x0EllObj = ellipsoid([10; 0], [1 0; 0 1]);
%   dirsMat = [1 -1; 1 1; 0 1]';
  dirsMat = [0 1; 1 -1; 1 2]';
 % L0 = [1 2]';
%   o.save_all = 1;
  rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec,'isRegEnabled',true, 'isJustCheck', false ,'regTol',1e-3);

  rsObj.plotByEa();
  rsObj.plotByIa();

end