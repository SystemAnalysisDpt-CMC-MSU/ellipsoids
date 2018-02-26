function ctback(varargin)
% Continuous-time system backward reachability test.

  if nargin == 1
    nDirs = varargin{1};
  else
    nDirs = 4;
  end
  aMat        = [0 1; 0 0];
  bMat        = [0; 1];
  SUBounds.center = {'0'};
  SUBounds.shape  = 2;
  timeVec        = [4 2];
  phiVec = linspace(0,pi,nDirs);
  dirsMat       = [sin(phiVec); cos(phiVec)];
  mEllObj        = 2*ell_unitball(2);

  sys      = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds);
  rsObj       = elltool.reach.ReachContinuous(sys, mEllObj, dirsMat,...
      timeVec, 'isRegEnabled',true, 'isJustCheck', false ,'regTol',1e-3);

  eaEllMat       = rsObj.get_ea(); %#ok<NASGU>
  iaEllMat       = rsObj.get_ia(); %#ok<NASGU>

end