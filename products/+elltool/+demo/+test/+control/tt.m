function tt(varargin)
% Continuous-time system reachability test.
  
  if nargin == 1
    nDirs = varargin{1};
  else
    nDirs = 4;
  end
  aCMat        = {'2' '0'; '0' 't'};
  bCMat        = {'0' 'exp(t)'; 'sqrt(t)' '0'};
  uBoundsEllObj = ell_unitball(2);
  timeVec        = [1.1 2];
  phiVec = linspace(0,pi,nDirs);
  dirsMat       = [sin(phiVec); cos(phiVec)];
  x0EllObj       = ell_unitball(2) + [1; -1];

  sys      = elltool.linsys.LinSysContinuous(aCMat, bCMat, uBoundsEllObj);
  rsObj       = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec);

  rsObj.plotByEa();
  rsObj.plotByIa();

	  
end