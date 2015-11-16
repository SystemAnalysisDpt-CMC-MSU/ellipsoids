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
PATCH_ALPHA = 0.3;
VIEW_ANGLE = [39 -35];
nTimeSteps = writerObj.FrameRate * (timeVec(2)-timeVec(1));
timeStepsVec = linspace(timeVec(1),timeVec(2),nTimeSteps);
timeStepsVec(1) = [];
numTransparency = 1;
nTimeSteps = nTimeSteps - 1;
plObj = rsObj.plotByEa;
firstMap = plObj.getPlotStructure.figToAxesToPlotHMap;
firstKey = firstMap.keys;
secondMap = firstMap(firstKey{1});
secondKey = secondMap.keys;
plotGroup = secondMap(secondKey{1});
set(plotGroup, 'Visible', 'off')
view(VIEW_ANGLE);
axis(axisConfVec);
grid off;
numElementsInGroup = size(plotGroup, 2);
numofPatch = 1;
typesGroupStruct = get(plotGroup, 'Type');
for iGroupElement = 1 : numElementsInGroup
    if  strcmp(typesGroupStruct{iGroupElement}, 'patch')
        numofPatch = iGroupElement;
    end
end
patchObj = plotGroup(numofPatch);
patchTimeVec = patchObj.Vertices(:, 1);
sizeVert = numel(patchTimeVec);
while patchTimeVec(numTransparency) < timeVec(1)
    numTransparency = numTransparency + 1;
end
patchObj.FaceVertexAlphaData = [PATCH_ALPHA .* ones(numTransparency, 1); zeros(sizeVert - numTransparency, 1)];
patchObj.AlphaDataMapping = 'none';
patchObj.EdgeAlpha = 'interp';
patchObj.FaceAlpha = 'interp';
set(plotGroup, 'Visible', 'on')
for iTimeStep = 1:nTimeSteps
    while patchTimeVec(numTransparency) < timeStepsVec(iTimeStep);
        numTransparency = numTransparency + 1;
    end
    patchObj.FaceVertexAlphaData = [PATCH_ALPHA .* ones(numTransparency, 1); zeros(sizeVert - numTransparency, 1)];
    set(gcf,'WindowStyle','normal');
    set(gcf,'units','normalized','outerposition',[0 0 1 1]);
    videoFrameObj = getframe(gcf);
    writeVideo(writerObj,videoFrameObj);
end
close('gcf')
end