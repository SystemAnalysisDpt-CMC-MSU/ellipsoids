
writerObj = VideoWriter('reach_info','MPEG-4');
writerObj.FrameRate = 15;
open(writerObj);
for i = 1:Properties.getNTimeGridPoints();
	t0 = tt(i);
	t1 = t0 + timeVec(end);
	x0 = xx(:, i);
	x0EllObj = x0 + Properties.getAbsTol()*ell_unitball(2);
	rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, [t0 t1],'isRegEnabled',true, 'isJustCheck', false ,'regTol',1e-3);

	ct = rsObj.cut(t1);
	ct.plotByEa('r'); hold on;
% 	ct.plotByIa('b'); hold on;
	ell_plot(x0, 'k*');
	axis([-25 70 -5 14]);
    hold off;

	frame = getframe(gcf);
    writeVideo(writerObj,frame);
    closereq;
end

close(writerObj);