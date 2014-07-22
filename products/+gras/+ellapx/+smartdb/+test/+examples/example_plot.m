% An example of calculating ellipsoid tube object projection using PROJECT
% function.
ellProjObj = gras.ellapx.smartdb.test.examples.example_getProj();
plObj=smartdb.disp.RelationDataPlotter();
ellProjObj.plot(plObj);