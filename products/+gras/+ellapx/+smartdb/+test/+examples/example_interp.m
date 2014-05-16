% An example of usage of INTERP function. In this example an ellipsoid tube
% object is created, using oldTimeVec time vector. Then it is interpolated 
% on newTimeVec time vector.
nTubes=1;
nPoints = 20;
timeBeg=0;
timeEnd=1;
type = 1;
ellTubeObj=...
    gras.ellapx.smartdb.test.examples.getEllTube(nTubes,timeBeg,timeEnd,type,nPoints);
newNPoints=50;
newTimeVec = (1/nPoints):(1/newNPoints):1;
interpEllTubeObj = ellTubeObj.interp(newTimeVec);