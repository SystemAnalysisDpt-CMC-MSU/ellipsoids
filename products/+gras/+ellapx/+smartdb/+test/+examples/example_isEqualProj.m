% An example of ISEQUAL method usage. The compared ellTubeProjections are 
% equal.
firstProjObj = gras.ellapx.smartdb.test.examples.getProj();
secondProjObj = gras.ellapx.smartdb.test.examples.getProj();
res = firstProjObj.isEqual(secondProjObj);