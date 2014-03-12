function tt
% Continuous-time system reachability test.

  aCMat        = {'2' '0'; '0' 't'};
  bCMat        = {'0' 'exp(t)'; 'sqrt(t)' '0'};
  uBoundsEllObj = ell_unitball(2);
  timeVec        = [1.1 2];
  dirsMat       = [1 0; 0 1; 1 1; -1 1]';
  x0EllObj       = ell_unitball(2) + [1; -1];

  sys      = elltool.linsys.LinSysContinuous(aCMat, bCMat, uBoundsEllObj);
  rsObj       = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec);

  rsObj.plotByEa(); hold on;
  rsObj.plotByIa(); hold on;

	  
end