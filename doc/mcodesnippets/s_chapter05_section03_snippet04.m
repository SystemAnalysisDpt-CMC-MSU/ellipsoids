function example
   nPoints=5;
   calcPrecision=0.001;
   approxSchemaDescr=char.empty(1,0);
   approxSchemaName=char.empty(1,0);
   nDims=3;
   nTubes=4;
   lsGoodDirVec=[1;0;1];
   aMat=zeros(nDims,nPoints);
   timeVec=1:nPoints;
   sTime=nPoints;
   approxType=gras.ellapx.enums.EApproxType.Internal;
   MArrayList=repmat({repmat(diag([0.1 0.2 0.3]),[1,1,nPoints])},1,nTubes);
   QArrayList=repmat({repmat(diag([1 2 3]),[1,1,nPoints])},1,nTubes);
   scaleFactor=1.01;
   projType=gras.ellapx.enums.EProjType.Static;
   projSpaceList={[1 0 0;0 0 1],[1 0 0;0 1 0]};
   ltGoodDirArray=repmat(lsGoodDirVec,[1,nTubes,nPoints]);
   gras.ellapx.smartdb.rels.EllTube.fromQMScaledArrays(QArrayList,aMat,...
     MArrayList,timeVec,ltGoodDirArray,sTime,approxType,approxSchemaName,...
     approxSchemaDescr,calcPrecision,scaleFactor(ones(1,nTubes)));
   fromMatEllTube=gras.ellapx.smartdb.rels.EllTube.fromQMArrays(QArrayList,...
     aMat, MArrayList,timeVec,ltGoodDirArray,sTime,approxType,...
     approxSchemaName,approxSchemaDescr,calcPrecision);
   ellTubeProj = fromMatEllTube.project(projType,projSpaceList,...
     @fGetProjMat);
   plObj=smartdb.disp.RelationDataPlotter();
   colorVec = [0 1 0];
   shade = 0.5;
   ellTubeProj.plot(plObj,'fGetTubeColor',@(x) deal(colorVec, shade));
end

function [projOrthMatArray,projOrthMatTransArray]=fGetProjMat(projMat,...
    timeVec,varargin)
  nTimePoints=length(timeVec);
  projOrthMatArray=repmat(projMat,[1,1,nTimePoints]);
  projOrthMatTransArray=repmat(projMat.',[1,1,nTimePoints]);
 end