function ctreach
% Continuous-time system reachability test.

clear P1;
  firstAMat        = [0 1; 0 0];
  thirdAMat  = [0 1; -2 0];
  secondACMat = {'0' '1-cos(2*t)'; '-2/(0.5+t)' '0'};
  firstBMat        = eye(2);
  secondBMat  = [0; 1];
  firstSUBounds.center = {'sin(t)'; 'cos(t)'};
  firstSUBounds.center = {'1'; '-1'};
  firstSUBounds.shape = [1 0; 0 1];
  secondSUBOunds.center = {'0'};
  secondSUBOunds.shape  = 1;
  SVBounds = ellipsoid(1);
  import elltool.conf.Properties;
  timeVec        = [0 5];
%   phi      = 0:0.1:pi;
%   dirsMat       = [cos(phi); sin(phi)];
  dirsMat       = [1 0; 0 1; 1 1; -1 1]';
  %L0       = [1 0]';
  x0EllObj       = ell_unitball(2);

  firstSys      = elltool.linsys.LinSysContinuous(thirdAMat, firstBMat, firstSUBounds);
  secondSys     = elltool.linsys.LinSysContinuous(secondACMat, firstBMat, firstSUBounds);
  thirdSys     = elltool.linsys.LinSysContinuous(firstAMat, firstBMat, firstSUBounds, secondBMat, SVBounds);
  
  rsObj       = elltool.reach.ReachContinuous(firstSys, x0EllObj, dirsMat, timeVec, 'isRegEnabled',true, 'isJustCheck', false ,'regTol',1e-3);

  rsObj.plotByEa(); hold on;
%  plotByIa(rs); hold on;

  rsObj = rsObj.evolve(10, secondSys);

  rsObj.plotByEa('r'); hold on;
%  plotByIa(rs, 'y'); hold on;
	  
%   rsObj = rsObj.evolve(15, thirdSys); %problem with regularization
% 
%   rsObj.plotByEa('g'); hold on;
%  plotByIa(rs, 'c'); hold on;

end