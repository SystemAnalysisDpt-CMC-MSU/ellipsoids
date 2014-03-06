 aCMat = {'0' '-2' '0' '0' '0' '0' '0' '0' '0' '0'
      '2' '0'  '0' '0' '0' '0' '0' '0' '0' '0'
      '0' '0'  'cos(t)' '0' '0' '0' '0' '0' '0' '0'
      '0' '0' '0' '0' '0' '0' '1' '0' '0' '0'
      '0' '0' '0' '0' '0' '-1' '0' '0' '0' '0'
      '0' '0' '0' '-1-(sin(2*t))^2' '0' '0' '0' '0' '0' '0'
      '0' '0' '0' '2' '0' '0' '0' '0' '0' '0'
      '0' '0' '0' '0' '0' '0' '0' '-0.5' '0' '0'
      '0' '0' '0' '0' '0' '0' '0' '0' '1+(1/t)' '0'
      '0' '0' '0' '0' '0' '0' '0' '0' '-2' '-1'};

 bMat = [1 0 0; 0 1 0; 0 0 1; -1 0 1; 0 0 0; 0 0 0; 1 1 1; 0 1 0; 0 0 0; 0 0 0];
 SUBounds.center = {'sin(2*t)'; '1+cos(t)'; '-1'};
 SUBounds.shape  = [4 -1 0; -1 1 0; 0 0 2];
 x0EllObj = ell_unitball(10) + [4 1 0 7 -3 -2 1 2 0 0]';

 sys = elltool.linsys.LinSysContinuous(aCMat, bMat, SUBounds);

 timeVec = [2 5];

%  dirsMat = [1 1 -1 0 1 0 0 0 -1 1; 0 1 0 1 0 -1 0 -1 0 1]';
 dirsMat = eye(10);

 rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec, 'isRegEnabled',true, 'isJustCheck', false ,'regTol',1e-4);

%  projBasisMat = [1 0 0 0 0 0 0 0 0 0; 0 0 1 0 0 0 0 0 0 0; 0 0 0 1 0 0 0 0 0 0]';
%  projBasisMat = [1 0 0 0 0 0 0 0 0 0; 0 0 1 0 0 0 0 0 0 0]';
 projBasisMat = [0 0 0 0 0 0 0 0 0 1; 0 0 1 0 0 0 0 0 0 0].';

 psObj=rsObj.projection(projBasisMat);

 psObj.plotByEa(); hold on; psObj.plotByIa();
