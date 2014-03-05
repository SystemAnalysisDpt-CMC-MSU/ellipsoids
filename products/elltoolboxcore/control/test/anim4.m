import elltool.conf.Properties;

C =0.25;
 aMat = [0 1; 0 0]; 
 bMat = [0; 1]; 
 SUBounds = ellipsoid(1);
 sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds);

 x0EllObj = Properties.getAbsTol()*ell_unitball(2);

 firstDirsMat = [-1 -1; 1 0; 0 1; 2 1; 3 1; 1 3; 1 2; -1 1; -2 1; -3 1; -1 3; -1 2]';

 timeVec = [0 6];
 rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, firstDirsMat, timeVec, 'isRegEnabled',true, 'isJustCheck', false ,'regTol',1e-3);
 eaEllMat = rsObj.cut(timeVec(end)).get_ea();

    eaEllMat  = inv(eaEllMat');
    approxSize   = size(eaEllMat, 2);
    dirsQuant   = Properties.getNPlot2dPoints()/2;
    phi = linspace(0, 2*pi, dirsQuant);
    secondDirsMat   = [cos(phi); sin(phi)];
    yy  = [];
    for dirsIterator = 1:dirsQuant
      l    = secondDirsMat(:, dirsIterator);
      mval = 0;
      for approxIterator = 1:approxSize
        Q = parameters(eaEllMat(1, approxIterator));
        v = l' * Q * l;
        if v > mval
          mval = v;
        end
      end
      x = l/realsqrt(mval);
      yy = [yy x];
    end
    yy = [timeVec(end)*ones(1, dirsQuant); yy];


 [xx, tt] = rsObj.get_goodcurves();
 LL       = rsObj.get_directions();
 xx = xx{1};
 xi = [timeVec(end); C*xx(:, end)];

   
