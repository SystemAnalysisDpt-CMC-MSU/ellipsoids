function circ
R = 2; 
L = 1; 
C = 0.1; 
aMat = [-R/L -1/L; 1/C 0]; 
bMat = [1/L; 0];
SUBounds = ellipsoid(1);

x0EllObj = ell_unitball(2);
timeVec  = [0 10];
dirsMat = [0 1; 1 1; 1 0; 1 -1]';

sys  = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds);
rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec, 'isRegEnabled',true, 'isJustCheck', false ,'regTol',1e-3);

rsObj.plotByEa(); hold on;
rsObj.plotByIa(); hold on;

end