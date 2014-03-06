function mech
 k1 = 50;
 k2 = 47;

 m1 = 1.5;
 m2 = 2;

 timeVec = [5 0];

 x0EllObj = 0.001*ell_unitball(4) + [2; 3; 0; 0];

 SUBounds = 5*ell_unitball(2);
 SVBounds = 0.32*ell_unitball(2);

 aMat = [0 0 1 0; 0 0 0 1; -(k1+k2)/m1 k2/m1 0 0; k2/m2 -(k1+k2)/m2 0 0];
 bMat = [0 0; 0 0; 1/m1 0; 0 1/m2];
 %B = [1 0 0 0; 0 1 0 0; 0 0 1/m1 0; 0 0 0 1/m2];
%  cMat = [0 0; 0 0; 1 0; 0 1];

 s = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds);
% s = linsys(aMat, bMat, SUBounds, cMat, SVBounds);
 
%  phi = 0:0.1:pi;
%  dirsMat  = [1 0 1 0; 1 -1 0 0; 0 -1 0 1]';
%  dirsMat  = [cos(phi); zeros(1,32); ones(1, 32); sin(phi)];
 dirsMat  = [-2 0 1 1; 0 -1 0 1]';
 rsObj = elltool.reach.ReachContinuous(s, x0EllObj, dirsMat, timeVec);

 prohBasisMat = [1 0 0 0; 0 1 0 0]';
 psObj = rsObj.projection(prohBasisMat);

 ps.Obj.plotByEa(); hold on;
 psObj.plotByIa(); hold on;

end