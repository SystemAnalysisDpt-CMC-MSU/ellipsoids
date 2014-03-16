function anim1(varargin)

  if nargin == 1
    nDirs = varargin{1};
  else
    nDirs = 4;
  end
import elltool.conf.Properties;

Properties.setNPlot2dPoints(1000)
aCMat = {'0' '-10'; '1/(2 + sin(t))' '-4/(2 + sin(t))'};
bCMat = {'10' '0'; '0' '1/(2 + sin(t))'};
SUBounds = struct();
SUBounds.center = [0; 0];
SUBounds.shape = {'4 - sin(t)' '-1'; '-1' '1 + (cos(t))^2'};

x0EllObj = ell_unitball(2);
timeVec  = [0 20];
firstDirVec = [1 1].';
secondDirVec = [-1 1].';
thirdDirsMat = [0 1; 1 0].';
phiVec = linspace(0,pi,nDirs);
forthDirsMat = [cos(phiVec); sin(phiVec)];

firstSys  = elltool.linsys.LinSysContinuous(aCMat, bCMat, SUBounds);
firstRsObj = elltool.reach.ReachContinuous(firstSys, x0EllObj, firstDirVec, timeVec);
secondRsObj = firstRsObj.refine(secondDirVec);
thirdRsObj = secondRsObj.refine(thirdDirsMat);
forthRsObj = elltool.reach.ReachContinuous(firstSys, x0EllObj, forthDirsMat, timeVec);

%%%%%%%%%%%%%%%%%%%%%%
axisConfVec = [0 timeVec(2) -40 40 -5 5];
writerObj = VideoWriter('anim1','MPEG-4');
writerObj.FrameRate = 10;
open(writerObj);
writerObj = getAnimation(firstRsObj,writerObj,[0,5],axisConfVec);
writerObj = getAnimation(secondRsObj,writerObj,[5,10],axisConfVec);
writerObj = getAnimation(thirdRsObj,writerObj,[10,15],axisConfVec);
writerObj = getAnimation(forthRsObj,writerObj,[15,20],axisConfVec);
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
    videoFrameObj = getframe(gcf);
    writeVideo(writerObj,videoFrameObj);
    closereq;
  end
end