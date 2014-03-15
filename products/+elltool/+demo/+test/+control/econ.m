function econ(varargin)
  a0Mat = [0.2 0 -0.4; 0 0 -0.6; 0 0.5 -1];
  a1Mat = [0.54 0 0.4; 0.06 0 0.6; 0.6 0 1];
  aMat  = [zeros(3, 3) eye(3); a0Mat a1Mat];

  b1Mat = [-1.6 0.8; -2.4 0.2; -4 2];
  bMat  = [zeros(3, 2); b1Mat];

  SUBounds.center = {'(k+7)/100'; '2'};
  SUBounds.shape  = [0.02 0; 0 1];

  x0EllObj = ellipsoid([1; 0.5; -0.5; 1.10; 0.55; 0], eye(6));

  sys = elltool.linsys.LinSysDiscrete(aMat, bMat, SUBounds, [], [], [], [], 'd');
  nSteps = 10;
  dirsMat = [1 0 0 0 0 0; 0 1 0 0 0 0; 0 0 1 0 0 1; 0 1 0 1 1 0; 0 0 -1 1 0 1; 0 0 0 -1 1 1]';
  rsobj = elltool.reach.ReachDiscrete(sys, x0EllObj, dirsMat, [0 nSteps]);

  prBasisMat = [0 0 0 0 1 0; 0 0 0 0 0 1]';
  psObj = rsobj.projection(prBasisMat);
  
  psObj.plotByEa();
  psObj.plotByIa();

end