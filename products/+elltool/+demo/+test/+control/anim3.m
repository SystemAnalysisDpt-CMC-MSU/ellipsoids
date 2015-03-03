function anim3(varargin)
  firstACMat = {'sin(0.3*t)' '-0.22' '0'; '0' '-1' '0'; '-0.5' '1' 'cos(0.2*t)'};
  secondAMat = [0 0 1; 0 0 0; -4 0 0];
  firstBMat = [0 1 1; 1 1 0; 1 0 1];
  secondBMat = [1 0; 0 0; 0 1];
  firstSUBounds = ellipsoid([1 0 0; 0 2 0; 0 0 2]);
  secondSUBounds.center = [0; 0];
  secondSUBounds.shape = {'2 - sin(2*t)' '0'; '0' '2- cos(3*t)'};
  timeVec  = [0 2];
  dirsMat = [1 0 0; 0 0 1;0 1 1;1 -1 1; 1 0 1; 1 1 0].';
  x0EllObj = ell_unitball(3);

  firstSys = elltool.linsys.LinSysContinuous(firstACMat, firstBMat, firstSUBounds);
  secondSys = elltool.linsys.LinSysContinuous(secondAMat, secondBMat, secondSUBounds);
  firstRsObj = elltool.reach.ReachContinuous(firstSys, x0EllObj, dirsMat,...
      timeVec, 'isRegEnabled',true, 'isJustCheck', false ,'regTol',1e-3);
  secondRsObj = firstRsObj.evolve(5, secondSys);
    
  %%%%%%%%%%%%%%%%%%%%%%
axisConfVec = [-20 20 -2 2 -30 30];
camposConfVec = [-20 -2 -30];
writerObj=getVideoWriter('anim3');
writerObj.FrameRate = 10;% use 15 for better granularity
open(writerObj);
writerObj = getAnimation(firstRsObj,writerObj,[0 2],axisConfVec,camposConfVec);
writerObj = getAnimation(secondRsObj,writerObj,[2 5],axisConfVec,camposConfVec);
close(writerObj);
  
end
function writerObj=getVideoWriter(objName)
profileNameList=arrayfun(@(x)x.Name,VideoWriter.getProfiles,...
    'UniformOutput',false);
PRIORITY_PROFILE_LIST={'MPEG-4','Motion JPEG AVI'};
profileName=profileNameList{find(ismember(profileNameList,...
    PRIORITY_PROFILE_LIST),1,'last')};
writerObj = VideoWriter(objName,profileName);
end
function writerObj = getAnimation(rsObj,writerObj,timeVec,axisConfVec,camposConfVec)
  nTimeSteps = writerObj.FrameRate * (timeVec(2)-timeVec(1));
  timeStepsVec = linspace(timeVec(1),timeVec(2),nTimeSteps);
  timeStepsVec(1) = [];
  nTimeSteps = nTimeSteps - 1;
  for iTimeSteps = 1:nTimeSteps
    rsObj.cut(timeStepsVec(iTimeSteps)).plotByIa('g'); 
    axis(axisConfVec);
    campos(camposConfVec);
    set(gcf,'WindowStyle','normal');
    set(gcf,'units','normalized','outerposition',[0 0 1 1]);    
    videoFrameObj = getframe(gcf);
    writeVideo(writerObj,videoFrameObj);
    closereq;
  end
end