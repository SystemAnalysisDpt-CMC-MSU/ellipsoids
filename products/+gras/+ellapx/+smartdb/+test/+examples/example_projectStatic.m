% Example of PROJECTSTATIC function usage for creating a projection of
% EllTubeUnion object.
unionEllTubeObj = ...
    gras.ellapx.smartdb.test.examples.getUnion();
projMatList = {[1 0;0 1]};
statEllTubeProjObj = unionEllTubeObj.projectStatic(projMatList);