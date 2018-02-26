% Test for discrete-time lin. regularization.
function dtreg(varargin)

  if nargin == 1
    nDirs = varargin{1};
  else
    nDirs = 4;
  end
  nSteps  = 20;
  
  aMat = [0 1; 0 0];
  bMat  = [0; 1];
  pEllObj  = ellipsoid(0, 1);
  x0EllObj = ell_unitball(2);
  phiVec = linspace(0,pi,nDirs);
  dirsMat  = [cos(phiVec); sin(phiVec)];
  
  dSys = elltool.linsys.LinSysDiscrete(aMat, bMat, pEllObj, [], [], [], [], 'd');
  
  rsObj = elltool.reach.ReachDiscrete(dSys, x0EllObj, dirsMat,...
      [0 nSteps],'isRegEnabled',true, 'isJustCheck', false ,'regTol',1e-6);
  eaEllMat  = rsObj.get_ea(); %#ok<NASGU>
  iaEllMat  = rsObj.get_ia(); %#ok<NASGU>
  
end