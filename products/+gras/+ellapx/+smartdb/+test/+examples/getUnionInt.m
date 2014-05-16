function unionEllTubeObj = getUnionInt()
nTubes=10;
nPoints = 20;
timeBeg=1;
timeEnd=2;
type = 1;
ellTubeObj = ...
    gras.ellapx.smartdb.test.examples.getEllTube(nTubes,...
    timeBeg,timeEnd,type,nPoints);
unionEllTubeObj = ...
    gras.ellapx.smartdb.rels.EllUnionTube.fromEllTubes(ellTubeObj);
end