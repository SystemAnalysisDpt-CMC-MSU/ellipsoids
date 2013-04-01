% define disturbance:
gMat = [0 0; 0 0; 1 0; 0 1];
vEll = 0.5*ell_unitball(2);
% linear system with disturbance
lsysd = elltool.linsys.LinSys(aMat, bMat, uBoundsEll, gMat, vEll); 
% reach set
rsdObj = elltool.reach.ReachContinuous(lsysd, X0Ell, dirsMat, timeVec); 
psdObj = rsdObj.projection(BB);  % reach set projection onto (x1, x2)
% plot projection of reach set external approximation:
subplot(2, 2, 3);
psObj.plot_ea;  % plot the whole reach tube
subplot(2, 2, 4);
psObj = psObj.cut(4)
psObj.plot_ea;  % plot reach set approximation at time t = 4
