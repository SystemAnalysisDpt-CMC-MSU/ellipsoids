% Examples of calculating ellipsoid tube object projection to basic orths 
% using PROJECTTOORTHS function. This is an example of projectToOrths usage 
% with one input variable. The default value of projection type is used.
nTubes=1;
nPoints = 20;
timeBeg=0;
timeEnd=1;
type = 1;
ellTubeObj=...
    gras.ellapx.smartdb.test.examples.getEllTube(nTubes,timeBeg,timeEnd,type,nPoints);
ellTubeProjObj = ellTubeObj.projectToOrths([1,2]);