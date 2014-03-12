function dtback
% Test for discrete-time lin. system backward reachability.


  aMat  = [cos(1) -sin(1); sin(1) cos(1)];
  bVec   = [0; 1];
  pEllObj   = ellipsoid(0, 1);
  mEllObj   = ellipsoid([-1; 2], [4 -1; -1 1]);
  N = 20;
  L0  = [1 1 0 1; 1 -1 1 0];

  dSys  = elltool.linsys.LinSysDiscrete(aMat, bVec, pEllObj, [], [], [], [], 'd');
  rsObj  = elltool.reach.ReachDiscrete(dSys, mEllObj, L0, [N 0]);
  extApprox   = rsObj.get_ea();
  intApprox   = rsObj.get_ia();
  
  EA  = (aMat^(-N)) * mEllObj;
  for i = 1:N
    F  = aMat^(N-i);
    Fi = inv(F);
    EA = [EA Fi*inv(aMat)*bVec*pEllObj];
  end

  
end