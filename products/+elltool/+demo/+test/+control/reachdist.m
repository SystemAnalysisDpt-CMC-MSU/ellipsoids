function reachdist(varargin)
  if nargin == 1
    nDirs = varargin{1};
  else
    nDirs = 4;
  end
  timeVec  = [0 5];
  w  = 1;
  aMat  = [0 1; -w 0];
  bMat  = eye(2);
  cVec = [0; 1];
  SUBounds.center = {'sin(t)'; 'cos(t)'};
  SUBounds.shape =  [9 0; 0 2];
  vBoundsEllObj  = 0.5*ell_unitball(1);
  sys  = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds, cVec, vBoundsEllObj);
  x0EllObj = ellipsoid([10; 0], [1 0; 0 1]);
  phiVec = linspace((5/8)*pi,(7/8)*pi,nDirs);
  dirsMat = [sin(phiVec);cos(phiVec)];
  rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec,...
      'isRegEnabled',true, 'isJustCheck', false ,'regTol',1e-3);

  rsObj.plotByEa();
  rsObj.plotByIa();

end