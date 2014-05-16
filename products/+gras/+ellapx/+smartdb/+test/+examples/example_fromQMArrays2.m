% An example of creating nTubes ellipsoid tube objects using fromQMArrays
% function with different types of approximation.
nPoints=10;
absTol=0.01;
relTol=0.01;
approxSchemaDescr={'Internal'; 'External'; 'External'};
approxSchemaName={'Internal'; 'External'; 'External'};
nDims=3;
nTubes=3;
lsGoodDirVec=[1;0;1];
aMat=zeros(nDims,nPoints);
timeVec=(1/nPoints):(1/nPoints):1;
sTime=timeVec(randi(nPoints,1));
approxType=[gras.ellapx.enums.EApproxType.Internal,...
    gras.ellapx.enums.EApproxType.External,...
    gras.ellapx.enums.EApproxType.External]';
mArrayList=repmat({repmat(diag([0.1 0.2 0.3]),[1,1,nPoints])},...
    1,nTubes);
qArrayList=repmat({repmat(diag([1 2 3]),[1,1,nPoints])},...
    1,nTubes);
ltGoodDirArray=repmat(lsGoodDirVec,[1,nTubes,nPoints]);
fromMatMEllTubeObj=gras.ellapx.smartdb.rels.EllTube.fromQMArrays(...
    qArrayList, aMat, mArrayList, timeVec,...
    ltGoodDirArray, sTime, approxType, approxSchemaName,...
    approxSchemaDescr, absTol, relTol);
