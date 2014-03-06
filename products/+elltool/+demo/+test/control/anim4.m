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
    aprEndTime  = [];
    for dirsIterator = 1:dirsQuant
      dirVec    = secondDirsMat(:, dirsIterator);
      maxVal = 0;
      for approxIterator = 1:approxSize
        qMat = parameters(eaEllMat(1, approxIterator));
        val = dirVec' * qMat * dirVec;
        if val > maxVal
          maxVal = val;
        end
      end
      normDirVec = dirVec/realsqrt(maxVal);
      aprEndTime = [aprEndTime normDirVec];
    end
    aprEndTime = [timeVec(end)*ones(1, dirsQuant); aprEndTime];


 [gcCVec, gcTimeVec] = rsObj.get_goodcurves();
 dirsCVec       = rsObj.get_directions();
 gcVec = gcCVec{1};
 xEnd = [timeVec(end); C*gcVec(:, end)];

  %%%%%%%%%%%%%%%%%%%%%%%%%%
  
  writerObj = VideoWriter('internal_point','MPEG-4');
writerObj.FrameRate = 15;
open(writerObj);
% set(gca,'nextplot','replacechildren');
 for gcIterator = 1:(size(gcVec,2)-1)
   x0 = C*gcVec(:, gcIterator);
   x0EllObj = x0 + Properties.getAbsTol()*ell_unitball(2);
   startTime = gcTimeVec(gcIterator);
   firstDirsMat = [];
   for approxIterator = 1:approxSize
	   secondDirsMat = dirsCVec{approxIterator};
	   firstDirsMat = [firstDirsMat secondDirsMat(:, gcIterator)];
   end
 endTime = timeVec(end);
   RsObj = elltool.reach.ReachContinuous(sys, x0EllObj, firstDirsMat, [startTime endTime], 'isRegEnabled',true, 'isJustCheck', false ,'regTol',1e-3);
   RsObj.plotByEa(); hold on;
   ell_plot(aprEndTime, 'r', 'LineWidth', 2);
   ell_plot(xEnd, 'ko');
   ell_plot([startTime; x0], 'k*');
   ell_plot([gcTimeVec(gcIterator:end); C*gcVec(:, gcIterator:end)], 'k');

   title(sprintf('Reach tube at time T = %d', startTime));
  axis([0 timeVec(end) -40 40 -6 6]);
   hold off;

    videoFrameObj = getframe(gcf);
   writeVideo(writerObj,videoFrameObj);
   closereq;
 end

close(writerObj);
 
end
