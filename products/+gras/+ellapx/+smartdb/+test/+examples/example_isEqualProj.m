% An example of ISEQUAL method usage. The compared ellTubeProjections are 
% equal.
firstProjObj = gras.ellapx.smartdb.test.examples.example_getProj();
secondProjObj = gras.ellapx.smartdb.test.examples.example_getProj();
res = firstProjObj.isEqual(secondProjObj);