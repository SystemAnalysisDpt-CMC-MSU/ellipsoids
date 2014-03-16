function dtdist(varargin)
  if nargin == 1
    nDirs = varargin{1};
  else
    nDirs = 4;
  end
aMat = [0.9 1;0 0.7];
bMat = [1 0; 0 1];
gMat = [0.4 0.02; 0.02 0.4];

x0EllObj = ell_unitball(2);

uEllObj = ell_unitball(2);
vEllObj = ell_unitball(2);

sys = elltool.linsys.LinSysDiscrete(aMat, bMat, uEllObj, gMat, vEllObj, [], [], 'd');

phiVec = linspace(0,pi,nDirs);
dirsMat = [cos(phiVec); sin(phiVec)];
nSteps = 10;

rs1Obj = elltool.reach.ReachDiscrete(sys, x0EllObj, dirsMat, [0 nSteps],...
    'isRegEnabled',true, 'isJustCheck', false ,'regTol',1e-4);


rs2Obj = elltool.reach.ReachDiscrete(sys, x0EllObj, dirsMat, [0 nSteps],...
    'isRegEnabled',true, 'isJustCheck', false ,'regTol',1e-4,'isMinMax',true);

rs1Obj.plotByEa();
rs2Obj.plotByEa('g');
end