function ellTubeProjObj = example_getProj()
nTubes=1;
nPoints = 20;
timeBeg=0;
timeEnd=1;
type = 1;
ellTubeObj=...
    gras.ellapx.smartdb.test.examples.getEllTube(nTubes,timeBeg,timeEnd,type,nPoints);
projType = gras.ellapx.enums.EProjType.Static;
projMat = [1 0; 0 1; 0 0]';
p = @gras.ellapx.smartdb.test.examples.fGetProjMat;
[ellTubeProjObj,indProj2OrigVec] = ellTubeObj.project(projType,...
    {projMat},p);
end