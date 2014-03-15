function reachdist5(varargin)
  timeVec  = [1 5];
  w  = 2;
  aCMat  = {'0' '1' '0' '0' '0'
        '-2' '0' '0' '0' '0'
	'0' '0' '-cos(2*t)' '0' '0'
	'0' '0' '0' '0' '1.5'
	'0' '0' '0' '-1' '0'};
  bMat  = eye(5);
  cMat  = eye(5);
  uBoundsEllObj  = ellipsoid([9 0 0 0 0; 0 2 0 0 0; 0 0 4 0 0; 0 0 0 4 0; 0 0 0 0 9]);
  vBoundsEllObj  = ellipsoid([1 0 0 0 0; 0 2 0 0 0; 0 0 3 0 0; 0 0 0 2 0; 0 0 0 0 1]);
  sys  = elltool.linsys.LinSysContinuous(aCMat, bMat, uBoundsEllObj, cMat, vBoundsEllObj);
  
  x0EllObj = ellipsoid([10; -1; 1; 0; -10], 36*eye(5));
  dirsMat = [0 1 -1 0 1; 0 1 1 0 0]';
  rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec,...
      'isRegEnabled',true, 'isJustCheck', false ,'regTol',1e-3);

end