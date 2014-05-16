% An example of GETDATA method's usage.
nTubes=5;
nPoints = 100;
timeBeg=0;
timeEnd=1;
type = 2;
ellTubeObj=...
    gras.ellapx.smartdb.test.examples.getEllTube(nTubes,timeBeg,timeEnd,type,nPoints);
data = ellTubeObj.getData();