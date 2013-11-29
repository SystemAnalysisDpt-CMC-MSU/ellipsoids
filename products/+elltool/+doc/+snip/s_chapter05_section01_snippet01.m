 centVec = [1 2]';
 shMat = eye(2, 2);
 ellObj = ellipsoid(centVec, shMat);
 ellObj = ellipsoid(shMat) + centVec;
 ellObj = sqrtm(shMat)*ell_unitball(size(shMat, 1)) + centVec;