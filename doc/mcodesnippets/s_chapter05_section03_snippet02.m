aMat = [0 1 0 0; -1 0 1 0; 0 0 0 1; 0 0 -1 0];
bMat = [0; 0; 0; 1];
uBoundsEll = ellipsoid(1);
sys = elltool.linsys.LinSys(aMat, bMat, uBoundsEll); % 4-dimensional system
dirsMat  = [1 1 0 1; 0 -1 1 0; -1 1 1 1; 0 0 -1 1]'; % matrix of directions
% reach set from time 0 to 5
rsObj = elltool.reach.ReachContinuous(sys, ell_unitball(4), dirsMat, [0 5]);
basisMat = [1 0 0 1; 0 1 1 0]';  % basis of 2-dimensional subspace

% project reach set rs onto basis basisMat
psObj = rsObj.projection(basisMat);
psObj.plot_ea;  % plot external approximation
hold on;
psObj.plot_ia;  % plot internal approximation