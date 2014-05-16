% An example of ISEQUAL method usage. The compared ellTubeUnions are not
% equal because one has external approximation, and the other has internal
% approximation.
firstUnionObj = gras.ellapx.smartdb.test.examples.getUnionExt();
secondUnionObj = gras.ellapx.smartdb.test.examples.getUnionInt();
res = firstUnionObj.isEqual(secondUnionObj);