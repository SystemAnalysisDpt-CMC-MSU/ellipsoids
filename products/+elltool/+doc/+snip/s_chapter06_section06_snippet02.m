% Creating projection matrix and drawing projection on axis (x_3, x_4)
velBasisMat = [0 0 1 0 ; 0 0 0 1]';
prTubeObj = solvObj.projection(velBasisMat);
plObj = smartdb.disp.RelationDataPlotter('figureGroupKeySuffFunc', ...
    @(x)sprintf('_forward_reach_set_proj%d',x));
prTubeObj.plotByEa('r',plObj);
hold on;
ylabel('x_3'); zlabel('x_4');
title('Ellipsoidal reach tube, proj. on subspace [0 0 1 0, 0 0 0 1]');
rotate3d on;