function anim2(varargin)
import elltool.conf.Properties;

  if nargin == 1
    nDirs = varargin{1};
  else
    nDirs = 4;
  end
thirdAMat = [0 1; -4 0];
thirdBMat = [1; 0];
SThirdUBounds = ell_unitball(1);
thirdSys = elltool.linsys.LinSysContinuous(thirdAMat, thirdBMat, SThirdUBounds);

secondACMat = {'0' '-10'; '1/(2 + sin(t))' '-4/(2 + sin(t))'};
secondBCMat = {'10' '0'; '0' '1/(2 + sin(t))'};
SSecondUBounds.center = [0; 0];
SSecondUBounds.shape = {'4 - sin(t)' '-1'; '-1' '1 + (cos(t))^2'};
secondSys = elltool.linsys.LinSysContinuous(secondACMat, secondBCMat, SSecondUBounds);

firstAMat = [0 1; -4 0];
firstBMat = [1; 0];
uBoundsEllObj = ell_unitball(1);
firstSys = elltool.linsys.LinSysContinuous(firstAMat, firstBMat, uBoundsEllObj);

x0EllObj = ell_unitball(2);

timeVec  = [0 5];
firstNewEndTime  = 10;
secondNewEndTime  = 15;

phiVec = linspace(0,pi,nDirs);
dirsMat  = [sin(phiVec); cos(phiVec)];
firstRsObj = elltool.reach.ReachContinuous(firstSys, x0EllObj, dirsMat,...
    timeVec, 'isRegEnabled',true, 'isJustCheck', false ,'regTol',1e-4);
secondRsObj = firstRsObj.evolve(firstNewEndTime, secondSys);
thirdRsObj = secondRsObj.evolve(secondNewEndTime, thirdSys);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
axisConfVec = [0 secondNewEndTime -50 50 -10 10];
writerObj = VideoWriter('anim2','MPEG-4');
writerObj.FrameRate = 10;
open(writerObj);
writerObj = getAnimation(firstRsObj,writerObj,[0 5],axisConfVec);
writerObj = getAnimation(secondRsObj,writerObj,[5 10],axisConfVec);
writerObj = getAnimation(thirdRsObj,writerObj,[10 15],axisConfVec);
close(writerObj);       

end

function writerObj = getAnimation(rsObj,writerObj,timeVec,axisConfVec)
  nTimeSteps = writerObj.FrameRate * (timeVec(2)-timeVec(1));
  timeStepsVec = linspace(timeVec(1),timeVec(2),nTimeSteps);
  timeStepsVec(1) = [];
  nTimeSteps = nTimeSteps - 1;
  for iTimeSteps = 1:nTimeSteps
    rsObj.cut([0 timeStepsVec(iTimeSteps)]).plotByEa(); 
    axis(axisConfVec);
    set(gcf,'WindowStyle','normal');
    set(gcf,'units','normalized','outerposition',[0 0 1 1]);    
    videoFrameObj = getframe(gcf);
    writeVideo(writerObj,videoFrameObj);
    closereq;
  end
end
