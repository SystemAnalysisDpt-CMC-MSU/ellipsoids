
% dt = 1/24;
% N = 24 * T(2)/4;
dt = 1/24;
N = 24 * timeVec(end)/4;
writerObj = VideoWriter('anim1','MPEG-4');
writerObj.FrameRate = 15;
open(writerObj);
for k = 1:N
  firstRsObj.cut([0 dt*(k)]).plotByEa(); 
%   rs1.cut([0 dt*(k-1)]).plotByIa(); hold off;
  axis([0 timeVec(2) -40 40 -5 5]);
  frame = getframe(gcf);
  writeVideo(writerObj,frame);
  closereq;
end
  
for k = (N+1):2*N
  secondRsObj.cut([0 dt*(k)]).plotByEa(); 
%   rs2.cut([0 dt*(k-1)]).plotByIa(); hold off;
%   axis([-20 20 -5 5]);
  axis([0 timeVec(2) -40 40 -5 5]);
  frame = getframe(gcf);
  writeVideo(writerObj,frame);
    closereq;
end

for k = (2*N+1):3*N
  thirdRsObj.cut([0 dt*(k)]).plotByEa(); 
%   rs3.cut([0 dt*(k-1)]).plotByIa(); hold off;
%   axis([-20 20 -5 5]);
  axis([0 timeVec(2) -40 40 -5 5]);
  frame = getframe(gcf);
  writeVideo(writerObj,frame);
    closereq;
end

for k = (3*N+1):4*N
  forthRsObj.cut([0 dt*(k)]).plotByEa(); 
%   rs4.cut([0 dt*(k-1)]).plotByIa(); hold off;
%   axis([-20 20 -5 5]);
  axis([0 timeVec(2) -40 40 -5 5]);
  frame = getframe(gcf);
  writeVideo(writerObj,frame);
  closereq;
end
close(writerObj);