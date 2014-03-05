
 writerObj = VideoWriter('reach_info3','MPEG-4');
writerObj.FrameRate = 15;
open(writerObj);
  for goodcurvesIterator = 1:200
    x0  = C * xx(:, goodcurvesIterator);
    x0EllObj  = x0 + Properties.getAbsTol()*ell_unitball(3);
%     x0EllObj  = x0 + 0.0001*ell_unitball(3);
    firstRsObj = elltool.reach.ReachContinuous(firstSys, x0EllObj, dirsMat, [tt(goodcurvesIterator) (tt(goodcurvesIterator)+3)],'isRegEnabled',true, 'isJustCheck', false ,'regTol',1e-3);
%     projBasisMat = [1 0 0; 0 1 0].';
    firstProjObj = firstRsObj.cut(tt(goodcurvesIterator)+3); 
%     firstProjObj = firstRsObj.projection(projBasisMat);
    firstProjObj.plotByEa('r'); hold on;
%     firstRsObj.plotByIa('b'); hold on;
    ell_plot(x0, 'k*');
    axis([0 20 -2 2 0 80]);
    campos([0 -2 10]);
    hold off;

    videoFrameObj = getframe(gcf);
    writeVideo(writerObj,videoFrameObj);
    closereq;
  end

close(writerObj);