function anim4

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

  %%%%%%%%%%%%%%%%%%%%%%%%%%
  
  writerObj = VideoWriter('internal_point','MPEG-4');
writerObj.FrameRate = 15;
open(writerObj);
% set(gca,'nextplot','replacechildren');
 for goodcurvesIterator = 1:199
   x0 = C*xx(:, goodcurvesIterator);
   x0EllObj = x0 + Properties.getAbsTol()*ell_unitball(2);
   t0 = tt(goodcurvesIterator);
   firstDirsMat = [];
   for approxIterator = 1:approxSize
	   secondDirsMat = LL{approxIterator};
	   firstDirsMat = [firstDirsMat secondDirsMat(:, goodcurvesIterator)];
   end
   T = timeVec(end);
   RsObj = elltool.reach.ReachContinuous(sys, x0EllObj, firstDirsMat, [t0 T], 'isRegEnabled',true, 'isJustCheck', false ,'regTol',1e-3);
   RsObj.plotByEa(); hold on;
   ell_plot(yy, 'r', 'LineWidth', 2);
   ell_plot(xi, 'ko');
   ell_plot([t0; x0], 'k*');
   ell_plot([tt(goodcurvesIterator:end); C*xx(:, goodcurvesIterator:end)], 'k');

   title(sprintf('Reach tube at time T = %d', t0));
  axis([0 timeVec(end) -40 40 -6 6]);
   hold off;

    videoFrameObj = getframe(gcf);
   writeVideo(writerObj,videoFrameObj);
   closereq;
 end

close(writerObj);
 
end
