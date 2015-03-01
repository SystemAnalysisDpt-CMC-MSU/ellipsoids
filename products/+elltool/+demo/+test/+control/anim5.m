function anim5(varargin)
import elltool.conf.Properties;

C = 1;
firstACMat = {'sin(3*t)' '-0.22' '0'; '0' '-1' '0'; '-0.5' '1' 'cos(0.2*t)'};
firstBMat = [0 1 0; 1 0 0;0 0 1];
firstSUBounds.center = [0; 0; 0];
firstSUBounds.shape = {'2 - sin(2*t)' '0' '0'; '0' '2- cos(3*t)' '0'; '0' '0' '1'};
timeVec  = [0 3];
dirsMat = [1 0 0; 0 0 1;0 1 1;1 -1 1; 1 0 1; 1 1 0]';
x0EllObj = [4 -2 5]' +Properties.getAbsTol()*ell_unitball(3);

firstSys = elltool.linsys.LinSysContinuous(firstACMat, firstBMat, firstSUBounds);
firstRsObj = elltool.reach.ReachContinuous(firstSys, x0EllObj, dirsMat,...
    timeVec, 'isRegEnabled',true, 'isJustCheck', false ,'regTol',1e-3);

[gcCVec, gcTimeVec] = firstRsObj.get_goodcurves();
gcVec = gcCVec{1};

%%%%%%%%%%%%%%%%%%%%%%

writerObj=getVideoWriter('anim5');
writerObj.FrameRate = 15;
open(writerObj);
for iGc = 1:(size(gcVec,2)-1)
    x0  = C * gcVec(:, iGc);
    x0EllObj  = x0 + Properties.getAbsTol()*ell_unitball(3);
    firstRsObj = elltool.reach.ReachContinuous(firstSys, x0EllObj, dirsMat,...
        [gcTimeVec(iGc) (gcTimeVec(iGc)+3)],'isRegEnabled',true,...
        'isJustCheck', false ,'regTol',1e-3);
    firstProjObj = firstRsObj.cut(gcTimeVec(iGc)+3);
    firstProjObj.plotByEa('r'); hold on;
    ell_plot(x0, 'k*');
    axis([0 20 -2 2 0 80]);
    campos([0 -2 10]);
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