function bigd(varargin)
 firstAMat = [0 1 0 0 0; -2 0 0 0 0; 0 0 -1 0 0; 0 0 0 0 0; 0 0 0 0 1];
 secondAMat = [-4 0 0 0 0; 0 -3 0 0 0; 0 0 0 0 0; 0 0 0 -1 1; 0 0 0 0 -1];
 thirdAMat = [0 0 0 0 0; -1 0 0 0 0; 0 0 -2 0 0; 0 2 0 0 0; 0 0 0 0 1];
 forthAMat = [0 1 0 0 0; 0 0 1 0 0; 0 0 0 0 0; 0 0 0 0 1; 0 0 0 -1 0];

 aMat = [firstAMat zeros(5, 5) zeros(5, 5) zeros(5, 5)
      zeros(5, 5) secondAMat zeros(5, 5) zeros(5, 5)
      zeros(5, 5) zeros(5, 5) thirdAMat zeros(5, 5)
      zeros(5, 5) zeros(5, 5) zeros(5, 5) forthAMat];
 bMat = [1 0 0; 0 1 0; 0 0 1; -1 0 1; 0 0 0; 0 0 0; 1 1 1; 0 1 0; 0 0 0; 0 0 0];
 bMat = [bMat zeros(10, 3); zeros(10, 3) -bMat];
 SUBOunds.center = {'sin(2*t)'; '1+cos(t)'; '-1'; '0'; '0'; 't^2'};
 SUBOunds.shape  = [4 -1 0 0 0 0; -1 2 0 0 0 0; 0 0 9 0 0 0; 0 0 0 4 0 0; 0 0 0 0 4 0; 0 0 0 0 0 4];
 x0EllObj = ell_unitball(20) + [4 1 0 7 -3 -2 1 2 0 0 1 -1 0 0 5 0 0 0 -1 -1]';

 sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBOunds);

 timeVec = [0 5];

 dirsMat = [1 1 -1 0 1 0 0 0 -1 1 0 1 0 1 0 -1 0 -1 0 1]';
 dirsMat = [dirsMat [1 0 1 0 0 0 0 0 0 1 0 1 0 1 0 -1 0 -1 0 1]'];
 dirsMat = [dirsMat [0 0 1 -1 0 0 0 0 0 0 0 1 0 1 0 0 0 0 0 -1]'];
 dirsMat = [dirsMat [-1 1 1 -1 0 0 0 0 0 0 0 1 0 1 0 0 0 0 0 -1]'];
 dirsMat = [dirsMat [-1 0 1 0 0 0 0 0 0 0 0 1 0 1 0 0 0 0 0 -1]'];

 rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec,...
     'isRegEnabled',true, 'isJustCheck', false ,'regTol',1e-3);

 projBasisMat = zeros(20, 2);
 projBasisMat(2, 1) = 1;
 projBasisMat(18, 2) = 1;

 psObj=rsObj.projection(projBasisMat);

 psObj.plotByEa();
 psObj.plotByIa();
 
 
end
