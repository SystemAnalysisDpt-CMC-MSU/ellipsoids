
dt = 1/24;
N = 24 * 5;
writerObj = VideoWriter('anim2','MPEG-4');
writerObj.FrameRate = 15;
open(writerObj);
for k = 1:N
  firstRsObj.cut([0 dt*(k)]).plotByEa('b');
%   firstRsObj.cut([0 dt*(k)]).plotByIa('y');
  axis([0 secondNewEndTime -50 50 -10 10]);
  frame = getframe(gcf);
  writeVideo(writerObj,frame);
  closereq;
end
  
for k = (N+1):2*N
  secondRsObj.cut([0 dt*(k)]).plotByEa('r');
%   secondRsObj.cut([0 dt*(k)]).plotByIa('g');
  axis([0 secondNewEndTime -50 50 -10 10]);
  frame = getframe(gcf);
  writeVideo(writerObj,frame);
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