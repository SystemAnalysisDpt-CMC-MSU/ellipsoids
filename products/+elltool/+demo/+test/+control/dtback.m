function dtback(varargin)
% Test for discrete-time lin. system backward reachability.
    
  if nargin == 1
    nDirs = varargin{1};
  else
    nDirs = 4;
  end
  aMat  = [cos(1) -sin(1); sin(1) cos(1)];
  bVec   = [0; 1];
  pEllObj   = ellipsoid(0, 1);
  mEllObj   = ellipsoid([-1; 2], [4 -1; -1 1]);
  phiVec = linspace(0,pi,nDirs);
  dirsMat  = [cos(phiVec); sin(phiVec)];
  nSteps = 10;
  dSys  = elltool.linsys.LinSysDiscrete(aMat, bVec, pEllObj, [], [], [], [], 'd');
  rsObj  = elltool.reach.ReachDiscrete(dSys, mEllObj, dirsMat, [nSteps 0]);
  eaEllObj   = rsObj.get_ea(); %#ok<NASGU>
  iaEllObj   = rsObj.get_ia(); %#ok<NASGU>
  
  ea2EllObj  = (aMat^(-nSteps)) * mEllObj;
  for iSteps = 1:nSteps
    fMat  = aMat^(nSteps-iSteps);
    ea2EllObj = [ea2EllObj (aMat*fMat)\bVec*pEllObj];  %#ok<AGROW>
  end

end