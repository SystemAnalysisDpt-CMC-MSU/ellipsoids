  timeVec  = [1 5];
  w  = 2;
  aCMat  = {'0' '1' '0' '0' '0'
        '-2' '0' '0' '0' '0'
	'0' '0' '-cos(2*t)' '0' '0'
	'0' '0' '0' '0' '1.5'
	'0' '0' '0' '-1' '0'};
  %A  = [0 1 0 0 0; -w 0 0 0 0; 0 0 -0.5 0 0; 0 0 0 0 1.5; 0 0 0 -1 0];
  bMat  = eye(5);
  cMat  = eye(5);
  SUBounds  = ellipsoid([9 0 0 0 0; 0 2 0 0 0; 0 0 4 0 0; 0 0 0 4 0; 0 0 0 0 9]);
  SVBounds  = ellipsoid([1 0 0 0 0; 0 2 0 0 0; 0 0 3 0 0; 0 0 0 2 0; 0 0 0 0 1]);
%   o.save_all = 1;
  sys  = elltool.linsys.LinSysContinuous(aCMat, bMat, SUBounds, cMat, SVBounds);
  
  x0EllObj = ellipsoid([10; -1; 1; 0; -10], 36*eye(5));
%   dirsMat = [0 1 -1 0 1; 0 1 1 0 0; 1 0 0 1 -1]';
  dirsMat = [0 1 -1 0 1; 0 1 1 0 0]';
%   o.save_all = 1;
  rsObj = elltool.reach.ReachContinuous(s, x0EllObj, dirsMat, timeVec,'isRegEnabled',true, 'isJustCheck', false ,'regTol',1e-3);
