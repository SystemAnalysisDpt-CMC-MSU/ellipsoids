function circ1(varargin)

  if nargin == 1
    nDirs = varargin{1};
  else
    nDirs = 4;
  end
R = 4;
L = 0.5;
C = 0.1; 
firstAMat = [0 -1/C; 1/L -R/L];
firstBMat = [1/C 0; 0 1/L];
secondACMat = {'0' '-10'; '1/(2 + sin(t))' '-4/(2 + sin(t))'};
secondBCMat = {'10' '0'; '0' '1/(2 + sin(t))'};
firstSUBounds = ell_unitball(2);
secondSUBounds.center = {'1000/(t^2)'; 'sin(2*t)'};
secondSUBounds.shape = [4 -1; -1 1];

x0EllObj = 0.0001*ell_unitball(2);
timeVec  = [0 10];
newEndTime = 20;
phiVec = linspace(0,pi,nDirs);
dirsMat = [sin(phiVec);cos(phiVec)];

firstSys  = elltool.linsys.LinSysContinuous(firstAMat, firstBMat, firstSUBounds);
secondSys  = elltool.linsys.LinSysContinuous(secondACMat, secondBCMat, secondSUBounds);
firstRsObj = elltool.reach.ReachContinuous(firstSys, x0EllObj, dirsMat,...
    timeVec, 'isRegEnabled',true, 'isJustCheck', false ,'regTol',1e-4);
secondRsObj = firstRsObj.evolve(newEndTime, secondSys);

firstRsObj.plotByEa();
firstRsObj.plotByIa();
secondRsObj.plotByEa('r');
secondRsObj.plotByIa('y');

end