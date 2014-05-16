% An example of calculating EllTubeUnion object's projection using PROJECT
% method. For EllTubeUnion objects the type of projection can only be Static.
unionEllTubeObj = ...
    gras.ellapx.smartdb.test.examples.getUnion();
projType = gras.ellapx.enums.EProjType.Static;
projMat = [1 0; 0 1]';
p = @gras.ellapx.smartdb.test.examples.fGetProjMat;
[ellTubeProjObj,indProj2OrigVec] = unionEllTubeObj.project(projType,...
    {projMat},p);