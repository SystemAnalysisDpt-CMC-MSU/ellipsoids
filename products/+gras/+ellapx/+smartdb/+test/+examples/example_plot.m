% An example of calculating ellipsoid tube object projection using PROJECT
% function.
ellProjObj = gras.ellapx.smartdb.test.examples.getProj();
plObj=smartdb.disp.RelationDataPlotter();
ellProjObj.plot(plObj);