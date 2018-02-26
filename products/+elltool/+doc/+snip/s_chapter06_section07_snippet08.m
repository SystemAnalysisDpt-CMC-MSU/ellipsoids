% create projection matrix and draw projection on current axis (z_1, z_2)
velBasisMat = [1 0 0 0 ; 0 1 0 0]';
prTubeObj = rsTubeObj.projection(velBasisMat);
prTubeObj.plotByIa();
hold on;
ylabel('z_1'); zlabel('z_2');
title('Elipsoidal reach tube, proj. on subspace [1 0 0 0 ; 0 1 0 0]');
rotate3d on;