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
    nApprox   = size(eaEllMat, 2);
    nDirs   = Properties.getNPlot2dPoints()/2;
    phiVec = linspace(0, 2*pi, nDirs);
    secondDirsMat   = [cos(phiVec); sin(phiVec)];
    aprEndTime  = [];
    for iDirs = 1:nDirs
      dirVec    = secondDirsMat(:, iDirs);
      maxVal = 0;
      for iApprox = 1:nApprox
        qMat = parameters(eaEllMat(1, iApprox));
        val = dirVec' * qMat * dirVec;
        if val > maxVal
          maxVal = val;
        end
      end
      normDirVec = dirVec/realsqrt(maxVal);
      aprEndTime = [aprEndTime normDirVec];
    end
    aprEndTime = [timeVec(end)*ones(1, nDirs); aprEndTime];


 [gcCVec, gcTimeVec] = rsObj.get_goodcurves();
 dirsCVec       = rsObj.get_directions();
 gcVec = gcCVec{1};
 xEnd = [timeVec(end); C*gcVec(:, end)];

  %%%%%%%%%%%%%%%%%%%%%%%%%%
  
  writerObj = VideoWriter('internal_point','MPEG-4');
writerObj.FrameRate = 15;
open(writerObj);
% set(gca,'nextplot','replacechildren');
 for iGc = 1:(size(gcVec,2)-1)
   x0 = C*gcVec(:, iGc);
   x0EllObj = x0 + Properties.getAbsTol()*ell_unitball(2);
   startTime = gcTimeVec(iGc);
   firstDirsMat = [];
   for iApprox = 1:nApprox
	   secondDirsMat = dirsCVec{iApprox};
	   firstDirsMat = [firstDirsMat secondDirsMat(:, iGc)];
   end
 endTime = timeVec(end);
   RsObj = elltool.reach.ReachContinuous(sys, x0EllObj, firstDirsMat, [startTime endTime], 'isRegEnabled',true, 'isJustCheck', false ,'regTol',1e-3);
   RsObj.plotByEa(); hold on;
   ell_plot(aprEndTime, 'r', 'LineWidth', 2);
   ell_plot(xEnd, 'ko');
   ell_plot([startTime; x0], 'k*');
   ell_plot([gcTimeVec(iGc:end); C*gcVec(:, iGc:end)], 'k');

   title(sprintf('Reach tube at time T = %d', startTime));
  axis([0 timeVec(end) -40 40 -6 6]);
   hold off;

    videoFrameObj = getframe(gcf);
   writeVideo(writerObj,videoFrameObj);
   closereq;
 end

close(writerObj);
 
end
