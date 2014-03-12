function dtreach
% Test for discrete-time lin. system forward reachability.

  aMat = [cos(1) -sin(1); sin(1) cos(1)];
  aMat = [0 1; -1 -0.5];
  bVec  = [0; 1];
  pEllObj  = ellipsoid(-1, 1);
  x0EllObj = ell_unitball(2) + [-2; 3];
  phiVec = 0:0.05:pi;
  firstDirsMat  = [1 1 0 1; 1 -1 1 0];
  secondDirsMat  = [cos(phiVec); sin(phiVec)];
  N = [1 10];
  dSys = elltool.linsys.LinSysDiscrete(aMat, bVec, pEllObj, [], [], [], [], 'd');
  rsObj = elltool.reach.ReachDiscrete(dSys, x0EllObj, firstDirsMat, N);

  rsObj.refine(secondDirsMat);
  rsObj.plotByEa(); hold on;
  rsObj.plotByIa();


  expApprox  = rsObj.get_ea();
  intApprox  = rsObj.get_ia();
  
  EA = (aMat^N(end)) * x0EllObj;
  for i = 1:N(end)
    EA = [EA (aMat^(N(end)-i))*bVec*pEllObj];
  end
end