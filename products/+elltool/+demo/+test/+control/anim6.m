function anim6(varargin)
import elltool.conf.Properties;
REG_TOL=1e-3;
N_FRAMES=15;
TIME_LIM_VEC=[0 5];
%
if nargin == 1
    nDirs = varargin{1};
else
    nDirs = 4;
end
Properties.setNPlot2dPoints(500);
Properties.setNTimeGridPoints(135);
aCMat = {'0' '-10'; '1/(2 + sin(t))' '-4/(2 + sin(t))'};
bCMat = {'10' '0'; '0' '1/(2 + sin(t))'};
SUBounds.center = {'10-t'; '1'};
SUBounds.shape = {'4 - sin(t)' '-1'; '-1' '1 + (cos(t))^2'};
sys = elltool.linsys.LinSysContinuous(aCMat, bCMat, SUBounds);
%
x0EllObj = Properties.getAbsTol()*ell_unitball(2);
%
phiVec = linspace(0,pi,nDirs);
dirsMat  = [sin(phiVec); cos(phiVec)];
rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat,...
    TIME_LIM_VEC,'isRegEnabled',true, 'isJustCheck', false ,'regTol',1e-3);
[xTouchGoodCurveMatList, timeVec] = rsObj.get_goodcurves();
xTouchGoodCurveMat = xTouchGoodCurveMatList{1};

%%%%%%%%%%%%%%%%%
writerObj=getVideoWriter('anim6');
%
writerObj.FrameRate = N_FRAMES;
open(writerObj);
nTimePoints=numel(timeVec);
for iTimePoint = 1:(nTimePoints-1)
    startTime = timeVec(iTimePoint);
    endTime = startTime + timeVec(end);
    x0Vec = xTouchGoodCurveMat(:, iTimePoint);
    x0EllObj = x0Vec + Properties.getAbsTol()*ell_unitball(2);
    rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat,...
        [startTime endTime],'isRegEnabled',true, 'isJustCheck', false ,...
        'regTol',REG_TOL);
    %
    ctObj = rsObj.cut(endTime);
    ctObj.plotByEa('r'); hold on;
    ell_plot(x0Vec, 'k*');
    axis([-25 70 -5 14]);
    hold off;
    set(gcf,'WindowStyle','normal');
    set(gcf,'units','normalized','outerposition',[0 0 1 1]);
    videoFrameObj = getframe(gcf);
    writeVideo(writerObj,videoFrameObj);
    closereq;
end
%
close(writerObj);
end
%
function writerObj=getVideoWriter(objName)
profileNameList=arrayfun(@(x)x.Name,VideoWriter.getProfiles,...
    'UniformOutput',false);
PRIORITY_PROFILE_LIST={'MPEG-4','Motion JPEG AVI'};
profileName=profileNameList{find(ismember(profileNameList,...
    PRIORITY_PROFILE_LIST),1,'last')};
writerObj = VideoWriter(objName,profileName);
end