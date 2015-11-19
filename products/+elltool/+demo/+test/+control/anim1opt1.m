function anim1opt1(varargin)

N_FRAMES = 5;% use 10 for better granularity

if nargin == 1
    nDirs = varargin{1};
else
    nDirs = 4;
end
import elltool.conf.Properties;
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
firstRsObj = elltool.reach.ReachContinuous(firstSys, x0EllObj,...
    firstDirVec, timeVec);
secondRsObj = firstRsObj.refine(secondDirVec);
thirdRsObj = secondRsObj.refine(thirdDirsMat);
forthRsObj = elltool.reach.ReachContinuous(firstSys, x0EllObj,...
    forthDirsMat, timeVec);

%%%%%%%%%%%%%
axisConfVec = [0 timeVec(2) -40 40 -5 5];
writerObj=getVideoWriter('anim1opt1');
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
ORTHS_TO_PROJECT = [1 2];
VIEW_ANGLE = [39 -35];
N_SPOINTS = 2000;
PATCH_ALPHA = 0.3;
import gras.ellapx.enums.EApproxType;
import gras.ellapx.enums.EProjType;
import gras.ellapx.smartdb.F;
import modgen.graphics.camlight;
approxType = gras.ellapx.enums.EApproxType.External;
projType = gras.ellapx.enums.EProjType.Static;
nTimeSteps = writerObj.FrameRate * (timeVec(2)-timeVec(1));
timeStepsVec = linspace(timeVec(1),timeVec(2),nTimeSteps);
timeStepsVec(1) = [];
nTimeSteps = nTimeSteps - 1;
ellTubeObj = rsObj.getEllTubeRel...
    .getTuplesFilteredBy(F.APPROX_TYPE, approxType)...
    .getTuplesFilteredBy('approxType', approxType);
ellTubeProjObj =ellTubeObj.projectToOrths(ORTHS_TO_PROJECT)...
    .getTuplesFilteredBy('projType', projType);
timeFromEllTubeVec = ellTubeProjObj.timeVec{1};
aMat = ellTubeProjObj.aMat{1};
qArr = cat(4, ellTubeProjObj.QArray{:});
numEndPloting = 1;
hold on;
grid off;
view(VIEW_ANGLE);
axis(axisConfVec);
while (timeFromEllTubeVec(numEndPloting) < timeVec(1))
    numEndPloting = numEndPloting + 1;
end
if numEndPloting ~= 1
    
    [vMat,fMat] = calcPoints(N_SPOINTS,...
        timeFromEllTubeVec(:, 1: numEndPloting),...
        qArr(:, :, 1:numEndPloting, :),aMat(:, 1:numEndPloting));
    vMat = vMat';
    patch('FaceColor', 'b', 'EdgeColor', 'none', 'DisplayName',...
        'Picture', 'FaceAlpha', PATCH_ALPHA, 'Faces', fMat,...
        'Vertices', vMat, 'EdgeLighting','phong','FaceLighting', 'phong');
    material('metal');
    set(gcf,'WindowStyle','normal');
end
for iTimeStep = 1:nTimeSteps
    numStartPloting = numEndPloting;
    while (timeFromEllTubeVec(numEndPloting) < timeStepsVec(iTimeStep))
        numEndPloting = numEndPloting + 1;
    end
    [vMat,fMat] = calcPoints(N_SPOINTS,...
        timeFromEllTubeVec(:, numStartPloting:numEndPloting),...
        qArr(:, :, numStartPloting:numEndPloting, :),...
        aMat(:,numStartPloting:numEndPloting));
    vMat = vMat';
    patch('FaceColor', 'b', 'EdgeColor', 'none', 'DisplayName',...
        'Picture','FaceAlpha', PATCH_ALPHA,'Faces',fMat,'Vertices',vMat,...
        'EdgeLighting','phong','FaceLighting','phong');
    material('metal');
    set(gcf,'WindowStyle','normal');
    set(gcf,'units','normalized','outerposition',[0 0 1 1]);
    videoFrameObj = getframe(gcf);
    writeVideo(writerObj,videoFrameObj);
end
close('gcf');
end


function [vMat,fMat] = calcPoints(nPlotPoints, timeVec,qArr, aMat)
%
nDims = 2;
[lGridMat, fMat] = gras.geom.tri.spheretriext(nDims, nPlotPoints);
lGridMat = lGridMat';
nDir = size(lGridMat, 2);
nTimePoints = size(timeVec, 2);
fMat = gras.geom.tri.elltube2tri(nDir,nTimePoints);
xMat = zeros(3,nDir*nTimePoints);
for iTime = 1:nTimePoints
    xSliceTimeVec = calcPointsExt(nDir,lGridMat,nDims,...
        squeeze(qArr(:,:,iTime,:)), aMat(:,iTime));
    xMat(:,(iTime-1)*nDir+1:iTime*nDir) =...
        [timeVec(iTime)*ones(1,nDir); xSliceTimeVec];
end
vMat = xMat;
end
%
function xMat = calcPointsExt(nDir,lGridMat,nDims,qArr, centerVec)
xMat = zeros(nDims,nDir);
nTubes = size(qArr,3);
distAllMat = zeros(nTubes,nDir);
boundaryPointsAllCMat = cell(nTubes,nDir);
for iDir = 1:nDir
    lVec = lGridMat(:,iDir);
    distVec = gras.gen.SquareMatVector...
        .lrDivideVec(qArr,...
        lVec);
    distAllMat(:,iDir) = distVec;
    for iTube = 1:nTubes
        boundaryPointsAllCMat{iTube,iDir} = lVec/realsqrt(distVec(iTube));
    end
end
[~,xInd] = max(distAllMat,[],1);
for iDir = 1:size(xInd,2)
    xMat(:,iDir) = boundaryPointsAllCMat{xInd(iDir),iDir}...
        +centerVec;
end
end