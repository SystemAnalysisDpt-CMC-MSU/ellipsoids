% Continuous-time system reachability test.

  aCMat        = {'2' '0'; '0' 't'};
  bCMat        = {'0' 'exp(t)'; 'sqrt(t)' '0'};
  SUBounds = ell_unitball(2);
  import elltool.conf.Properties;
  timeVec        = [1.1 2];
%   phi      = 0:0.1:pi;
%   dirsMat       = [cos(phi); sin(phi)];
  dirsMat       = [1 0; 0 1; 1 1; -1 1]';
  %L0       = [1 1; 1 -1]';
  x0EllObj       = ell_unitball(2) + [1; -1];

  sys      = elltool.linsys.LinSysContinuous(aCMat, bCMat, SUBounds);
  rsObj       = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec);

  rsObj.plotByEa(); hold on;
  rsObj.plotByIa(); hold on;

	  
