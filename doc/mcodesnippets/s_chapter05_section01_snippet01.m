 centVec = [1 2]';
 shMat = eye(2, 2);
 ell = ellipsoid(centVec, shMat);
 ell = ellipsoid(shMat) + centVec;
 ell = sqrtm(shMat)*ell_unitball(size(shMat, 1)) + centVec;