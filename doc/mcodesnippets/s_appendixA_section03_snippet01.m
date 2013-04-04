for k = 1:20
   atMat = {'0' '1 + cos(pi*k/2)'; '-2' '0'};
   btMat =  [0; 1];
   uBoundsEllObj = ellipsoid(4);
   gtMat = [1; 0];
   distBounds = 1/(k+1);
   ctVec = [1 0];
   lsys = elltool.linsys.LinSysFactory.create(atMat, btMat, uBoundsEllObj, gtMat,...
          distBounds, ctVec, [], 'd');end