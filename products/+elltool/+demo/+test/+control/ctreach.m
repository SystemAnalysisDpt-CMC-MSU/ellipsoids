function ctreach(varargin)
% Continuous-time system reachability test.
  if nargin == 1
    nDirs = varargin{1};
  else
    nDirs = 4;
  end
  
  firstAMat        = [0 1; 0 0];
  thirdAMat  = [0 1; -2 0];
  secondACMat = {'0' '1-cos(2*t)'; '-2/(0.5+t)' '0'};
  firstBMat        = eye(2);
  cMat  = [0; 1];
  firstSUBounds.center = {'sin(t)'; 'cos(t)'};
  firstSUBounds.center = {'1'; '-1'};
  firstSUBounds.shape = [1 0; 0 1];
  SVBounds = ellipsoid(0.1);
  import elltool.conf.Properties;
  timeVec        = [0 5];
  phiVec = linspace(0,pi,nDirs);
  dirsMat       = [sin(phiVec);cos(phiVec)];
  x0EllObj       = ell_unitball(2);

  firstSys = elltool.linsys.LinSysContinuous(thirdAMat, firstBMat, firstSUBounds);
  secondSys = elltool.linsys.LinSysContinuous(secondACMat, firstBMat, firstSUBounds);
  thirdSys = elltool.linsys.LinSysContinuous(firstAMat, firstBMat,...
             firstSUBounds, cMat, SVBounds);
  
  rsObj = elltool.reach.ReachContinuous(firstSys, x0EllObj, dirsMat,...
      timeVec, 'isRegEnabled',true, 'isJustCheck', false ,'regTol',1e-5);

  rsObj.plotByEa();
  rsObj.plotByIa();

  rsObj = rsObj.evolve(10, secondSys);

  rsObj.plotByEa('r');
  rsObj.plotByIa('y');
	  
  rsObj = rsObj.evolve(15, thirdSys);

  rsObj.plotByEa('g');
  rsObj.plotByIa('c');

end