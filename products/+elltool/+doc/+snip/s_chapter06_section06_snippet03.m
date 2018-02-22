% Creating projection matrix and draw projection on axis (x_1, x_2)
condBasisMat = [1 0 0 0 ; 0 1 0 0]';
prTubeObj = solvObj.projection(condBasisMat);
plObj = smartdb.disp.RelationDataPlotter('figureGroupKeySuffFunc', ...
    @(x)sprintf('_forward_reach_set_proj%d',x));
prTubeObj.plotByEa('r',plObj);
hold on;
ylabel('x_1'); zlabel('x_2');
title('Ellipsoidal reach tube, proj. on subspace [1 0 0 0, 0 1 0 0]');
rotate3d on;