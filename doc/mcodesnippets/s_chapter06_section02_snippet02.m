% define disturbance:
gMat = [0 0; 0 0; 1 0; 0 1];
vEllObj = 0.05*ell_unitball(2);
% linear system with disturbance
lsysd = elltool.linsys.LinSysContinuous(aMat, bMat, uBoundsEllObj,...
    gMat, vEllObj); 
% reach set
rsdObj = elltool.reach.ReachContinuous(lsysd, x0EllObj, dirsMat,...
    timeVec, 'isRegEnabled', true, 'isJustCheck', false, 'regTol', 1e-1); 
psdObj = rsdObj.projection(basisMat);  % reach set projection onto (x1, x2)
% plot projection of reach set external approximation:
psdObj.plotEa();  % plot the whole reach tube
psdCutObj = psdObj.cut(4);
psdCutObj.plotEa();  % plot reach set approximation at time t = 4
