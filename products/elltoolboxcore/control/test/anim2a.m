
dt = 1/24;
timeIntervalsQuant = 24 * 5;
writerObj = VideoWriter('anim2','MPEG-4');
writerObj.FrameRate = 15;
open(writerObj);
for timeIntervalsIterator = 1:timeIntervalsQuant
  firstRsObj.cut([0 dt*(timeIntervalsIterator)]).plotByEa('b');
%   firstRsObj.cut([0 dt*(k)]).plotByIa('y');
  axis([0 secondNewEndTime -50 50 -10 10]);
  videoFrameObj = getframe(gcf);
  writeVideo(writerObj,videoFrameObj);
  closereq;
end
  
for timeIntervalsIterator = (timeIntervalsQuant+1):2*timeIntervalsQuant
  secondRsObj.cut([0 dt*(timeIntervalsIterator)]).plotByEa('r');
%   secondRsObj.cut([0 dt*(k)]).plotByIa('g');
  axis([0 secondNewEndTime -50 50 -10 10]);
  videoFrameObj = getframe(gcf);
  writeVideo(writerObj,videoFrameObj);
  closereq;
end

% for k = (2*N+1):3*N
%   thirdRsObj.cut([0 dt*(k)]).plotByEa('m');
% %   thirdRsObj.cut([0 dt*(k)]).plotByIa('c');
%   axis([0 secondNewEndTime -50 50 -10 10]);
%   frame = getframe(gcf);
%   writeVideo(writerObj,frame);
%   closereq;
% end
close(writerObj);