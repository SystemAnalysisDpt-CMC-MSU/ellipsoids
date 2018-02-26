%%
%check whether the point belongs to the reachability tube
[iaEllMat, timeVec] = prTubeObj.get_ia();
x2Vec = [v, c]';
firstEllObj = x1Vec + ellipsoid(qMat);
iaEllMat.isinternal(x2Vec, 'u')