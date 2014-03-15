function ctreach3D(varargin)
% Continuous-time system reachability test in 3D.

  aCMat        = {'sin(0.3*t)' '-0.22' '0'; '0' '-1' '0'; '-0.5' '1' 'cos(0.2*t)'};
  bMat        = [0 1 1; 1 1 0; 1 0 1];
  SUBounds.center = {'sin(2*t)'; 'cos(2*t)'; '1'};
  SUBounds.shape  = [1 0 0; 0 2 0; 0 0 2];
  timeVec        = [1 2];
  dirsMat       = [1 0 0; 0 0 1;0 1 1;1 -1 1; 1 0 1; 1 1 0]';
  x0EllObj       = ell_unitball(3) + [1; -1; -1];

  sys      = elltool.linsys.LinSysContinuous(aCMat, bMat, SUBounds);
  rsObj       = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat,...
      timeVec, 'isRegEnabled',true, 'isJustCheck', false ,'regTol',1e-3);

  eaEllMat        = rsObj.get_ea();
  iaEllMat        = rsObj.get_ia();

end