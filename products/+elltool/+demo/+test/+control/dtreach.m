function dtreach(varargin)
% Test for discrete-time lin. system forward reachability.
  aMat = [0 1; -1 -0.5];
  bVec  = [0; 1];
  pEllObj  = ellipsoid(-1, 1);
  x0EllObj = ell_unitball(2) + [-2; 3];
  phiVec = 0:0.05:pi;
  dirs0Mat  = [1 1 0 1; 1 -1 1 0];
  dirs1Mat  = [cos(phiVec); sin(phiVec)];
  nSteps = 20;
  
  dSys = elltool.linsys.LinSysDiscrete(aMat, bVec, pEllObj, [], [], [], [], 'd');
  rsObj = elltool.reach.ReachDiscrete(dSys, x0EllObj, dirs0Mat, [0 nSteps]);

  rsObj = rsObj.refine(dirs1Mat);
  rsObj.plotByEa();
  rsObj.plotByIa();


  eaEllArr  = rsObj.get_ea();
  iaEllArr  = rsObj.get_ia();
  
  ea2EllArr = (aMat^nSteps) * x0EllObj;
  for iSteps = 1:nSteps
    ea2EllArr = [ea2EllArr (aMat^(nSteps-iSteps))*bVec*pEllObj];
  end

end