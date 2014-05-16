% Examples of calculating ellipsoid tube object static projection using 
% PROJECTSTATIC function.
nTubes=1;
nPoints = 20;
timeBeg=0;
timeEnd=1;
type = 1;
ellTubeObj=...
    gras.ellapx.smartdb.test.examples.getEllTube(nTubes,timeBeg,timeEnd,type,nPoints);
projMat = [1 0; 0 1; 0 0]';
ellTubeProjObj = ellTubeObj.projectStatic(projMat);