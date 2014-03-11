function anim3
  firstACMat = {'sin(0.3*t)' '-0.22' '0'; '0' '-1' '0'; '-0.5' '1' 'cos(0.2*t)'};
  secondAMat = [0 0 1; 0 0 0; -4 0 0];
  firstBMat = [0 1 1; 1 1 0; 1 0 1];
  secondBMat = [1 0; 0 0; 0 1];
  firstSUBounds = ellipsoid([1 0 0; 0 2 0; 0 0 2]);
  secondSUBounds.center = [0; 0];
  secondSUBounds.shape = {'2 - sin(2*t)' '0'; '0' '2- cos(3*t)'};
  timeVec  = [0 2];
  dirsMat = [1 0 0; 0 0 1;0 1 1;1 -1 1; 1 0 1; 1 1 0]';
  x0EllObj = ell_unitball(3);

  firstSys = elltool.linsys.LinSysContinuous(firstACMat, firstBMat, firstSUBounds);
  secondSys = elltool.linsys.LinSysContinuous(secondAMat, secondBMat, secondSUBounds);
  firstRsObj = elltool.reach.ReachContinuous(firstSys, x0EllObj, dirsMat, timeVec, 'isRegEnabled',true, 'isJustCheck', false ,'regTol',1e-3);
  secondRsObj = evolve(firstRsObj, 5, secondSys);
    
  %%%%%%%%%%%%%%%%%%%%%%
  
  
  dt = 1/24;

writerObj = VideoWriter('switch3_a','MPEG-4');
writerObj.FrameRate = 15;
open(writerObj);
for timeIntervalsIterator = 1:48
  firstRsObj.cut(dt*(timeIntervalsIterator)).plotByEa('b');
%   firstRsObj.cut([0 dt*(k)]).plotByIa('y');
  axis([-20 20 -2 2 -30 30]);
  %campos([-10 -1 10]);
  campos([-20 -2 -30]);
  videoFrameObj = getframe(gcf);
  writeVideo(writerObj,videoFrameObj);
  closereq;
end

for timeIntervalsIterator = 49:120
  firstRsObj.cut(dt*(timeIntervalsIterator)).plotByEa('r');
%   firstRsObj.cut([0 dt*(k)]).plotByIa('g');
  axis([-20 20 -2 2 -30 30]);
  campos([-20 -2 -30]);
  videoFrameObj = getframe(gcf);
  writeVideo(writerObj,videoFrameObj);
  closereq;
end
close(writerObj);
  
end