function degdist(varargin)
  if nargin == 1
    nDirs = varargin{1};
  else
    nDirs = 4;
  end
  timeVec  = [0 5];
  w  = 2;
  aMat  = [0 1; -w 0];
  bMat  = eye(2);
  cMat  = eye(2);
  SUBounds  = ellipsoid([0.9 0; 0 0.1]);
  SVBounds  = ellipsoid([0.1 0; 0 0.3]);
  sys  = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds, cMat, SVBounds);
  
  x0EllObj = ellipsoid([10; 0], [0.5 0; 0 0.5]);
  phiVec = linspace(0,pi,nDirs);
  dirsMat = [sin(phiVec); cos(phiVec)];
  rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec,...
      'isRegEnabled',true, 'isJustCheck', false ,'regTol',1e-5); %#ok<NASGU>

end