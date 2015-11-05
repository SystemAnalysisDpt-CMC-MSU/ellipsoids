function anim1opt(varargin)

N_FRAMES = 5;% use 10 for better granularity

if nargin == 1
    nDirs = varargin{1};
else
    nDirs = 4;
end
import elltool.conf.Properties;
import gras.geom.*;
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

%%%%%%%%%%%%%
axisConfVec = [0 timeVec(2) -40 40 -5 5];
writerObj=getVideoWriter('anim1opt');
%
writerObj.FrameRate = N_FRAMES;
open(writerObj);
writerObj = getAnimation(firstRsObj,writerObj,[0,5],axisConfVec);
writerObj = getAnimation(secondRsObj,writerObj,[5,10],axisConfVec);
writerObj = getAnimation(thirdRsObj,writerObj,[10,15],axisConfVec);
writerObj = getAnimation(forthRsObj,writerObj,[15,20],axisConfVec);
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

function writerObj = getAnimation(rsObj,writerObj,timeVec,axisConfVec)
cla;
nTimeSteps = writerObj.FrameRate * (timeVec(2)-timeVec(1));
timeStepsVec = linspace(timeVec(1),timeVec(2),nTimeSteps);
timeStepsVec(1) = [];
nTimeSteps = nTimeSteps - 1;
ellTubeObj = rsObj.getEllTubeRel;
timeFromEllTubeVec = ellTubeObj.timeVec{2};
aMat = ellTubeObj.aMat{2};
QArray = ellTubeObj.QArray{2};
numEndPloting = 1;
hold on;
view(axes,[39.6 -35.6]);
axis(axisConfVec);
while (timeFromEllTubeVec(numEndPloting) < timeVec(1))
    numEndPloting = numEndPloting + 1;
end
if (numEndPloting ~= 1)
    [vMat,fMat] = gras.geom.tri.elltubetri(QArray(:,:,1:numEndPloting),aMat(:,1:numEndPloting),...
                                           timeFromEllTubeVec(:,1:numEndPloting), 1000);
    patch('FaceColor', 'b', 'EdgeColor', 'none', 'DisplayName', 'Picture','FaceAlpha', 0.3,...
          'Faces',fMat,'Vertices',vMat, 'EdgeLighting','phong','FaceLighting','phong');
    material('metal');
    set(gcf,'WindowStyle','normal');
end
for iTimeSteps = 1:nTimeSteps
    numStartPloting = numEndPloting;
    while (timeFromEllTubeVec(numEndPloting) < timeStepsVec(iTimeSteps))
        numEndPloting = numEndPloting + 1;
    end
    [vMat,fMat] = gras.geom.tri.elltubetri(QArray(:,:,numStartPloting:numEndPloting), aMat(:,numStartPloting:numEndPloting),...
                                           timeFromEllTubeVec(:,numStartPloting:numEndPloting), 1000);
    patch('FaceColor', 'b', 'EdgeColor', 'none', 'DisplayName', 'Picture','FaceAlpha', 0.3,...
          'Faces',fMat,'Vertices',vMat, 'EdgeLighting','phong','FaceLighting','phong');
    material('metal');
    set(gcf,'WindowStyle','normal');
    set(gcf,'units','normalized','outerposition',[0 0 1 1]);
    videoFrameObj = getframe(gcf);
    writeVideo(writerObj,videoFrameObj);
end
close('gcf');
end