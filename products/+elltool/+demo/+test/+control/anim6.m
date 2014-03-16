function anim6(varargin)
import elltool.conf.Properties;

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

x0EllObj = Properties.getAbsTol()*ell_unitball(2);

timeVec = [0 5];
phiVec = linspace(0,pi,nDirs);
dirsMat  = [sin(phiVec); cos(phiVec)];
rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat,...
    timeVec,'isRegEnabled',true, 'isJustCheck', false ,'regTol',1e-3);
[gcCVec, gcTimeVec] = rsObj.get_goodcurves();
gcVec = gcCVec{1};

%%%%%%%%%%%%%%%%%
writerObj = VideoWriter('anim6','MPEG-4');
writerObj.FrameRate = 15;
open(writerObj);
for iGc = 1:(size(gcVec,2)-1)
	startTime = gcTimeVec(iGc);
    endTime = startTime + timeVec(end);
	x0 = gcVec(:, iGc);
	x0EllObj = x0 + Properties.getAbsTol()*ell_unitball(2);
	rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat,...
        [startTime endTime],'isRegEnabled',true, 'isJustCheck', false ,'regTol',1e-3);

	ctObj = rsObj.cut(endTime);
	ctObj.plotByEa('r'); hold on;
	ell_plot(x0, 'k*');
	axis([-25 70 -5 14]);
    hold off;

	videoFrameObj = getframe(gcf);
    writeVideo(writerObj,videoFrameObj);
    closereq;
end

close(writerObj);

end