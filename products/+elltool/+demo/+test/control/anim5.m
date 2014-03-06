function anim5

import elltool.conf.Properties;

  C = 1;
  firstACMat = {'sin(3*t)' '-0.22' '0'; '0' '-1' '0'; '-0.5' '1' 'cos(0.2*t)'};
  firstBMat = [0 1 0; 1 0 0;0 0 1];
  firstSUBounds.center = [0; 0; 0];
  firstSUBounds.shape = {'2 - sin(2*t)' '0' '0'; '0' '2- cos(3*t)' '0'; '0' '0' '1'};
  timeVec  = [0 3];
  dirsMat = [1 0 0; 0 0 1;0 1 1;1 -1 1; 1 0 1; 1 1 0]';
  x0EllObj = [4 -2 5]' +Properties.getAbsTol()*ell_unitball(3);

  firstSys = elltool.linsys.LinSysContinuous(firstACMat, firstBMat, firstSUBounds);
  firstRsObj = elltool.reach.ReachContinuous(firstSys, x0EllObj, dirsMat, timeVec, 'isRegEnabled',true, 'isJustCheck', false ,'regTol',1e-3);

  [xx, tt] = firstRsObj.get_goodcurves();
  xx = xx{1};

  %%%%%%%%%%%%%%%%%%%%%%

  writerObj = VideoWriter('reach_info3','MPEG-4');
writerObj.FrameRate = 15;
open(writerObj);
  for goodcurvesIterator = 1:200
    x0  = C * xx(:, goodcurvesIterator);
    x0EllObj  = x0 + Properties.getAbsTol()*ell_unitball(3);
%     x0EllObj  = x0 + 0.0001*ell_unitball(3);
    firstRsObj = elltool.reach.ReachContinuous(firstSys, x0EllObj, dirsMat,...
        [tt(goodcurvesIterator) (tt(goodcurvesIterator)+3)],'isRegEnabled',true, 'isJustCheck', false ,'regTol',1e-3);
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
  
end