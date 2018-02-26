% create projection matrix and draw projection on current axis (z_2, z_4)
velBasisMat = [0 1 0 0 ; 0 0 0 1]';
prTubeObj = rsTubeObj.projection(velBasisMat);
prTubeObj.plotByIa();
hold on;
ylabel('z_2'); zlabel('z_4');
title('Elipsoidal reach tube, proj. on subspace [0 1 0 0 ; 0 0 0 1]');
rotate3d on; 