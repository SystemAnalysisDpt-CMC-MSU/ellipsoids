% define disturbance:
gMat = [0 0; 0 0; 1 0; 0 1];
vEllObj = 0.5*ell_unitball(2);
% linear system with disturbance
lsysd = elltool.linsys.LinSysContinuous(aMat, bMat, uBoundsEllObj,...
    gMat, vEllObj); 
% reach set
rsdObj = elltool.reach.ReachContinuous(lsysd, x0EllObj, dirsMat,...
    timeVec, 'isRegEnabled', true, 'isJustCheck', false, 'regTol', 1e-1); 
psdObj = rsdObj.projection(BB);  % reach set projection onto (x1, x2)
% plot projection of reach set external approximation:
subplot(2, 2, 3);
psObj.plotEa();  % plot the whole reach tube
subplot(2, 2, 4);
psObj = psObj.cut(4);
psObj.plotEa();  % plot reach set approximation at time t = 4
