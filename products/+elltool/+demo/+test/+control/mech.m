function mech
 k1 = 50;
 k2 = 47;

 m1 = 1.5;
 m2 = 2;

 timeVec = [5 0];
 x0EllObj = 0.001*ell_unitball(4) + [2; 3; 0; 0];
 SUBounds = 5*ell_unitball(2);
 aMat = [0 0 1 0; 0 0 0 1; -(k1+k2)/m1 k2/m1 0 0; k2/m2 -(k1+k2)/m2 0 0];
 bMat = [0 0; 0 0; 1/m1 0; 0 1/m2];

 sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds);
 dirsMat  = [-2 0 1 1; 0 -1 0 1]';
 rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec);

 prohBasisMat = [1 0 0 0; 0 1 0 0]';
 psObj = rsObj.projection(prohBasisMat);

 psObj.plotByEa(); hold on;
 psObj.plotByIa(); hold on;

end