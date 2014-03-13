function dtback
% Test for discrete-time lin. system backward reachability.

  aMat  = [cos(1) -sin(1); sin(1) cos(1)];
  bVec   = [0; 1];
  pEllObj   = ellipsoid(0, 1);
  mEllObj   = ellipsoid([-1; 2], [4 -1; -1 1]);
  phiVec = 0:0.1:2*pi;
  dirsMAt  = [cos(phiVec); sin(phiVec)];
  nSteps = 10;
  dSys  = elltool.linsys.LinSysDiscrete(aMat, bVec, pEllObj, [], [], [], [], 'd');
  rsObj  = elltool.reach.ReachDiscrete(dSys, mEllObj, dirsMAt, [nSteps 0]);
  eaEllObj   = rsObj.get_ea();
  iaEllObj   = rsObj.get_ia();
  
  ea2EllObj  = (aMat^(-nSteps)) * mEllObj;
  for iSteps = 1:nSteps
    fMat  = aMat^(nSteps-iSteps);
    invFMat = inv(fMat);
    ea2EllObj = [ea2EllObj invFMat*inv(aMat)*bVec*pEllObj];
  end

end