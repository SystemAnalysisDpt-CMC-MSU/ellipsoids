

dt = 1/24;

writerObj = VideoWriter('switch3_a','MPEG-4');
writerObj.FrameRate = 15;
open(writerObj);
for k = 1:48
  firstRsObj.cut(dt*(k)).plotByEa('b');
%   firstRsObj.cut([0 dt*(k)]).plotByEa('y');
  axis([-20 20 -2 2 -30 30]);
  %campos([-10 -1 10]);
  campos([-20 -2 -30]);
  frame = getframe(gcf);
  writeVideo(writerObj,frame);
  closereq;
end

for k = 49:120
  firstRsObj.cut(dt*(k)).plotByEa('r');
%   firstRsObj.cut([0 dt*(k)]).plotByEa('g');
  axis([-20 20 -2 2 -30 30]);
  campos([-20 -2 -30]);
  frame = getframe(gcf);
  writeVideo(writerObj,frame);
  closereq;
end
close(writerObj);
