% Examples of calculating an ellipsoid tube object projection to basic orths 
% using PROJECTTOORTHS function. This is an example of projectToOrths usage 
% with specified projection type.
nTubes=1;
nPoints = 20;
timeBeg=0;
timeEnd=1;
type = 1;
ellTubeObj=...
    gras.ellapx.smartdb.test.examples.getEllTube(nTubes,timeBeg,timeEnd,type,nPoints);
projType = gras.ellapx.enums.EProjType.DynamicAlongGoodCurve;
ellTubeProjObj = ellTubeObj.projectToOrths([1,2], projType);