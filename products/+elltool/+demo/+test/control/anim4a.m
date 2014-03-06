 clear MM;
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