function ctback
% Continuous-time system backward reachability test.

  aMat        = [0 1; 0 0];
  bMat        = [0; 1];
  SUBounds.center = {'0'};
  SUBounds.shape  = 2;
  timeVec        = [4 2];
%   phi      = 0:0.1:2*pi;
%   dirsMat       = [cos(phi); sin(phi)];
  dirsMat       = [1 0; 0 1; 1 1; -1 1]';
  mEllObj        = 2*ell_unitball(2);

  sys      = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds);
  rsObj       = elltool.reach.ReachContinuous(sys, mEllObj, dirsMat, timeVec, 'isRegEnabled',true, 'isJustCheck', false ,'regTol',1e-3);

  eaEllMat       = rsObj.get_ea();
  iaEllMat       = rsObj.get_ia();

end