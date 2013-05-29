k1 = 24;  k2 = 32;
m1 = 1.5; m2 = 1;
% define matrices aMat, bMat, and control bounds uBoundsEll:
aMat = [0 0 1 0; 0 0 0 1; -(k1+k2)/m1 k2/m1 0 0; k2/m2 -(k1+k2)/m2 0 0];
bMat = [0 0; 0 0; 1/m1 0; 0 1/m2];
uEll = ell_unitball(2);
timeVec = [0 4];
x0Ell = [0 2 0 0].' +...
    ellipsoid([0.01 0 0 0; 0 0.01 0 0; 0 0 0 0; 0 0 0 0]);
% initial directions:
l0Mat = [1 0 1 0; 1 -1 0 0; 0 -1 0 1; 1 1 -1 1; -1 1 1 0; -2 0 1 1].';
% define disturbance:
gMat = [0 0; 0 0; 1 0; 0 1];
vEll = 0.5*ell_unitball(2);
% linear system with disturbance
lsysd = elltool.linsys.LinSysContinuous(aMat, bMat, uEll, gMat, vEll); 
% reach set
rsdObj = elltool.reach.ReachContinuous(lsysd, x0Ell, l0Mat, timeVec,...
    'isRegEnabled', true, 'isJustCheck', false, 'regTol', 1e-1); 