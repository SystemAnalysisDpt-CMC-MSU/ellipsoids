function anim1
import elltool.conf.Properties;

Properties.setNPlot2dPoints(1000)
aCMat = {'0' '-10'; '1/(2 + sin(t))' '-4/(2 + sin(t))'};
bCMat = {'10' '0'; '0' '1/(2 + sin(t))'};
%U = ell_unitball(2);
SUBounds = struct();
SUBounds.center = [0; 0];
SUBounds.shape = {'4 - sin(t)' '-1'; '-1' '1 + (cos(t))^2'};

x0EllObj = ell_unitball(2);
timeVec  = [0 20];
firstDirVec = [1 1].';
secondDirVec = [-1 1].';
thirdDirsMat = [0 1; 1 0].';
phi = 0:0.1:pi;
forthDirsMat = [cos(phi); sin(phi)];

firstSys  = elltool.linsys.LinSysContinuous(aCMat, bCMat, SUBounds);
firstRsObj = elltool.reach.ReachContinuous(firstSys, x0EllObj, firstDirVec, timeVec);
secondRsObj = firstRsObj.refine(secondDirVec);
thirdRsObj = secondRsObj.refine(thirdDirsMat);
forthRsObj = elltool.reach.ReachContinuous(firstSys, x0EllObj, forthDirsMat, timeVec);

%%%%%%%%%%%%%%%%%%%%%%


% dt = 1/24;
% N = 24 * T(2)/4;
dt = 1/24;
timeIntervalsQuant = 24 * timeVec(end)/4;
writerObj = VideoWriter('anim1','MPEG-4');
writerObj.FrameRate = 15;
open(writerObj);
for timeIntervalsIterator = 1:timeIntervalsQuant
  ellTubeObj = firstRsObj.ge
  firstRsObj.cut([0 dt*(timeIntervalsIterator)]).plotByEa(); 
%   rs1.cut([0 dt*(k-1)]).plotByIa(); hold off;
  axis([0 timeVec(2) -40 40 -5 5]);
  videoFrameObj = getframe(gcf);
  writeVideo(writerObj,videoFrameObj);
  closereq;
end
  
for timeIntervalsIterator = (timeIntervalsQuant+1):2*timeIntervalsQuant
  secondRsObj.cut([0 dt*(timeIntervalsIterator)]).plotByEa(); 
%   rs2.cut([0 dt*(k-1)]).plotByIa(); hold off;
%   axis([-20 20 -5 5]);
  axis([0 timeVec(2) -40 40 -5 5]);
  videoFrameObj = getframe(gcf);
  writeVideo(writerObj,videoFrameObj);
    closereq;
end

for timeIntervalsIterator = (2*timeIntervalsQuant+1):3*timeIntervalsQuant
  thirdRsObj.cut([0 dt*(timeIntervalsIterator)]).plotByEa(); 
%   rs3.cut([0 dt*(k-1)]).plotByIa(); hold off;
%   axis([-20 20 -5 5]);
  axis([0 timeVec(2) -40 40 -5 5]);
  videoFrameObj = getframe(gcf);
  writeVideo(writerObj,videoFrameObj);
    closereq;
end

for timeIntervalsIterator = (3*timeIntervalsQuant+1):4*timeIntervalsQuant
  forthRsObj.cut([0 dt*(timeIntervalsIterator)]).plotByEa(); 
%   rs4.cut([0 dt*(k-1)]).plotByIa(); hold off;
%   axis([-20 20 -5 5]);
  axis([0 timeVec(2) -40 40 -5 5]);
  videoFrameObj = getframe(gcf);
  writeVideo(writerObj,videoFrameObj);
  closereq;
end
close(writerObj);

end