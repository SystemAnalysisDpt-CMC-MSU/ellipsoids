% An example of creating nTubes ellipsoid tube objects using fromQArrays
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
qArrayList=repmat({repmat(diag([1 2 3]),[1,1,nPoints])},...
    1,nTubes);
ltGoodDirArray=repmat(lsGoodDirVec,[1,nTubes,nPoints]);
fromMatEllTubeObj=gras.ellapx.smartdb.rels.EllTube.fromQArrays(...
    qArrayList, aMat, timeVec,...
    ltGoodDirArray, sTime, approxType, approxSchemaName,...
    approxSchemaDescr, absTol, relTol);
