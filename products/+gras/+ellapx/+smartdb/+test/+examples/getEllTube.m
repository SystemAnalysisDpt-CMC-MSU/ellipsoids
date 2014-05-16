% An example of creating an ellipsoid tube object containing nTubes
% ellipsoid tubes from timeBegin to timeEnd time with specified type of
% approximation.
%
function ellTubeObj = getEllTube(nTubes,timeBeg,timeEnd,type,nPoints)
nDims=3;
absTol=0.001;
relTol=0.001;
timeVec=(timeBeg+1/nPoints):(1/nPoints):timeEnd;
sTime=timeVec(randi(nPoints,1));
lsGoodDirVec=[1;0;0];
ltGoodDirArray=repmat(lsGoodDirVec,[1,nTubes,nPoints]);
aMat=zeros(nDims,nPoints);
qArrayList=repmat({repmat(diag([1 2 3]),[1,1,nPoints])},1,nTubes);
if type == 1
    approxSchemaDescr='Internal';
    approxSchemaName='Internal';
    approxType=gras.ellapx.enums.EApproxType.Internal;
else
    approxSchemaDescr='External';
    approxSchemaName='External';
    approxType=gras.ellapx.enums.EApproxType.External;
end
ellTubeObj=gras.ellapx.smartdb.rels.EllTube.fromQArrays(...
    qArrayList, aMat, timeVec,...
    ltGoodDirArray, sTime, approxType, approxSchemaName,...
    approxSchemaDescr, absTol, relTol);
end