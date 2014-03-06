function anim2

import elltool.conf.Properties;

thirdAMat = [0 1; -4 0];
thirdBMat = [1; 0];
thirdSUBounds = ell_unitball(1);
thirdSys = elltool.linsys.LinSysContinuous(thirdAMat, thirdBMat, thirdSUBounds);

secondACMat = {'0' '-10'; '1/(2 + sin(t))' '-4/(2 + sin(t))'};
secondBCMat = {'10' '0'; '0' '1/(2 + sin(t))'};
secondSUBounds.center = [0; 0];
secondSUBounds.shape = {'4 - sin(t)' '-1'; '-1' '1 + (cos(t))^2'};
secondSys = elltool.linsys.LinSysContinuous(secondACMat, secondBCMat, secondSUBounds);

firstAMat = [0 1; -4 0];
firstBMat = [1; 0];
firstSUBounds = ell_unitball(1);
% C1 = [0; 1];
% V1 = ellipsoid(0.05);
firstSys = elltool.linsys.LinSysContinuous(firstAMat, firstBMat, firstSUBounds);

x0EllObj = ell_unitball(2);

timeVec  = [0 5];
firstNewEndTime  = 10;
secondNewEndTime  = 15;

dirsMat  = [1 0; 2 1; 1 1; 1 2; 0 1; -1 2; -1 1; -2 1]';
firstRsObj = elltool.reach.ReachContinuous(firstSys, x0EllObj, dirsMat, timeVec, 'isRegEnabled',true, 'isJustCheck', false ,'regTol',1e-4);
secondRsObj = firstRsObj.evolve(firstNewEndTime, secondSys);
% thirdRsObj = secondRsObj.evolve(secondNewEndTime, thirdSys); % problem with regularization
% thirdRsObj = elltool.reach.ReachContinuous(thirdSys,x0EllObj,dirsMat,...
%             [timeVec(1) secondNewEndTime],'isRegEnabled',true, 'isJustCheck', false ,'regTol',1e-4);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
%   videoFrameObj = getframe(gcf);
%   writeVideo(writerObj,frame);
%   closereq;
% end
close(writerObj);       

end
