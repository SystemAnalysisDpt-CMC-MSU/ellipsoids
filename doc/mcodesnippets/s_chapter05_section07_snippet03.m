nDims=2;
nTubes=3;
calcPrecision=0.001;
cutTimeVec = [20, 80];
timeVec = 1 : 100;
evolveTimeVec = 101 : 200;
fieldToExcludeList = {'sTime','lsGoodDirVec'};
nPoints = numel(timeVec);
aMat=zeros(nDims,nPoints);
 QArray = zeros(nDims,nDims,nPoints);
for iPoint = 1:nPoints
    QArray(:,:,iPoint) = timeVec(iPoint)*eye(nDims);
end
QArrayList=repmat({QArray},1,nTubes);
ltSingleGoodDirArray = zeros(nDims,1,nPoints);
for iPoint = 1:nPoints
   ltSingleGoodDirArray(:,:,iPoint) = timeVec(iPoint)*eye(nDims,1);
end
ltGoodDirArray=repmat(ltSingleGoodDirArray,1,nTubes);
rel = gras.ellapx.smartdb.rels.EllTube.fromQArrays(QArrayList,aMat,...
          timeVec,ltGoodDirArray,timeVec(1),...
          gras.ellapx.enums.EApproxType.Internal,char.empty(1,0),...
          char.empty(1,0),calcPrecision);
cutRel = rel.cut(cutTimeVec);
