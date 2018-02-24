function ctreach4(varargin)
  timeVec = [0 5];
  aMat = [0 1 0 0; -1 0 1 0; 0 0 0 1; 0 0 -1 0];
  bMat = [0; 0; 0; 1];

  x0EllObj = ell_unitball(4) + [1; 1; 0; -1];
  SUBounds  = ellipsoid(1);

  sys  = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds);

  dirsMat  = [1 1 0 1; 0 -1 1 0; -1 1 1 1; 0 0 -1 1]';
  rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec,...
      'isRegEnabled',true, 'isJustCheck', false ,'regTol',1e-3); %#ok<NASGU>

end