for k = 1:20
   atMat = {'0' '1 + cos(pi*k/2)'; '-2' '0'};
   btMat =  [0; 1];
   uBoundsEll = ellipsoid(4);
   gtMat = [1; 0];
   distBounds = 1/(k+1);
   ctArr = [1 0];
   lsys = elltool.linsys.LinSys(atMat, btMat, uBoundsEll, gtMat, distBounds, ctArr, [], 'd');
end