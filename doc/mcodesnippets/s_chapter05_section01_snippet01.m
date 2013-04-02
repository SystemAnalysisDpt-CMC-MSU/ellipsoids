 q = [1 2]';
 Q = eye(2, 2);
 E = ellipsoid(q, Q);
 E = ellipsoid(Q) + q;
 E = sqrtm(Q)*ell_unitball(size(Q, 1)) + q;