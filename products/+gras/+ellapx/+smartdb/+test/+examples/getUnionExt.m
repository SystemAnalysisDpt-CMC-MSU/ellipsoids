function unionEllTubeObj = getUnionExt()
nTubes=10;
nPoints = 20;
timeBeg=1;
timeEnd=2;
type = 2;
ellTubeObj = ...
    gras.ellapx.smartdb.test.examples.getEllTube(nTubes,...
    timeBeg,timeEnd,type,nPoints);
unionEllTubeObj = ...
    gras.ellapx.smartdb.rels.EllUnionTube.fromEllTubes(ellTubeObj);
end