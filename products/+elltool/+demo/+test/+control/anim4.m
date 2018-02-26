function anim4(varargin)
import elltool.conf.Properties;

if nargin == 1
    nDirs = varargin{1};
else
    nDirs = 4;
end
C =0.25;
aMat = [0 1; 0 0];
bMat = [0; 1];
SUBounds = ellipsoid(1);
sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds);

x0EllObj = Properties.getAbsTol()*ell_unitball(2);
phiVec = linspace(0,pi,nDirs);
firstDirsMat = [sin(phiVec); cos(phiVec)];

timeVec = [0 6];
rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, firstDirsMat,...
    timeVec, 'isRegEnabled',true, 'isJustCheck', false ,'regTol',1e-3);
eaEllMat = rsObj.cut(timeVec(end)).get_ea();

eaEllMat  = inv(eaEllMat');
nApprox   = size(eaEllMat, 2);
nDirs   = Properties.getNPlot2dPoints()/2;
phiVec = linspace(0, 2*pi, nDirs);
secondDirsMat   = [cos(phiVec); sin(phiVec)];
aprEndTime  = [];
for iDirs = 1:nDirs
    dirVec    = secondDirsMat(:, iDirs);
    maxVal = 0;
    for iApprox = 1:nApprox
        qMat = parameters(eaEllMat(1, iApprox));
        val = dirVec' * qMat * dirVec;
        if val > maxVal
            maxVal = val;
        end
    end
    normDirVec = dirVec/realsqrt(maxVal);
    aprEndTime = [aprEndTime normDirVec]; %#ok<AGROW>
end
aprEndTime = [timeVec(end)*ones(1, nDirs); aprEndTime];


[gcCVec, gcTimeVec] = rsObj.get_goodcurves();
dirsCVec       = rsObj.get_directions();
gcVec = gcCVec{1};
xEnd = [timeVec(end); C*gcVec(:, end)];

%%%%%%%%%%%%%%%%%%%%%%%%%%

writerObj=getVideoWriter('anim4');
writerObj.FrameRate = 1;
open(writerObj);
for iGc = 1:(size(gcVec,2)-1)
    x0 = C*gcVec(:, iGc);
    x0EllObj = x0 + Properties.getAbsTol()*ell_unitball(2);
    startTime = gcTimeVec(iGc);
    firstDirsMat = [];
    for iApprox = 1:nApprox
        secondDirsMat = dirsCVec{iApprox};
        firstDirsMat = [firstDirsMat secondDirsMat(:, iGc)]; %#ok<AGROW>
    end
    endTime = timeVec(end);
    RsObj = elltool.reach.ReachContinuous(sys, x0EllObj, firstDirsMat,...
        [startTime endTime], 'isRegEnabled',true, 'isJustCheck', false ,'regTol',1e-3);
    RsObj.plotByEa(); hold on;
    ell_plot(aprEndTime, 'r', 'LineWidth', 2);
    ell_plot(xEnd, 'ko');
    ell_plot([startTime; x0], 'k*');
    ell_plot([gcTimeVec(iGc:end); C*gcVec(:, iGc:end)], 'k');
    
    title(sprintf('Reach tube at time T = %d', startTime));
    axis([0 timeVec(end) -40 40 -6 6]);
    hold off;
    set(gcf,'WindowStyle','normal');
    set(gcf,'units','normalized','outerposition',[0 0 1 1]);
    videoFrameObj = getframe(gcf);
    writeVideo(writerObj,videoFrameObj);
    closereq;
end
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
