
% dt = 1/24;
% N = 24 * T(2)/4;
dt = 1/24;
timeIntervalsQuant = 24 * timeVec(end)/4;
writerObj = VideoWriter('anim1','MPEG-4');
writerObj.FrameRate = 15;
open(writerObj);
for timeIntervalsIterator = 1:timeIntervalsQuant
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