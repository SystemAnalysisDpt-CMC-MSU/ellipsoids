function example
   aMat = [0 1; 0 0]; bMat = eye(2);  
   SUBounds = struct();
   SUBounds.center = {'sin(t)'; 'cos(t)'};  
   SUBounds.shape = [9 0; 0 2]; 
   sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds);
   x0EllObj = ell_unitball(2);
   timeVec = [0 10]; 
   dirsMat = [1 0; 0 1]';  
   rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec);
   ellTubeObj = rsObj.getEllTubeRel();
   unionEllTube = ...
    gras.ellapx.smartdb.rels.EllUnionTube.fromEllTubes(ellTubeObj);
   projSpaceList = {[1 0;0 1]};
   projType = gras.ellapx.enums.EProjType.Static;
   statEllTubeProj = unionEllTube.project(projType,projSpaceList,...
      @fGetProjMat);
   plObj=smartdb.disp.RelationDataPlotter();
   statEllTubeProj.plot(plObj);
end

function [projOrthMatArray,projOrthMatTransArray]=fGetProjMat(projMat,...
    timeVec,varargin)
  nTimePoints=length(timeVec);
  projOrthMatArray=repmat(projMat,[1,1,nTimePoints]);
  projOrthMatTransArray=repmat(projMat.',[1,1,nTimePoints]);
 end