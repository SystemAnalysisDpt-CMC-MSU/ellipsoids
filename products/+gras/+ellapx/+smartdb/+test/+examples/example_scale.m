% An example of using SCALE method to calculate and set new
% scaleFactor for fields in ellipsoid tube object.
nTubes=1;
nPoints = 20;
timeBeg=0;
timeEnd=1;
type = 1;
ellTubeObj=...
    gras.ellapx.smartdb.test.examples.getEllTube(nTubes,timeBeg,timeEnd,type,nPoints);
newnPoints=50;
newTimeVec = (1/nPoints):(1/newnPoints):1;
interpEllTubeObj = ellTubeObj.interp(newTimeVec);
ellTubeObj.scale(@(varargin)2,{});