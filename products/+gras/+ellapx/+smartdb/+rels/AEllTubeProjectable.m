classdef AEllTubeProjectable<handle
    methods (Abstract)
        % PROJECT - computes projection of the relation object onto given time
        %           dependent subspase
        %
        %
        % Input:
        %  regular:
        %    self.
        %    projType - type of the projection.
        %        Takes the following values: 'Static'
        %                                    'DynamicAlongGoodCurve'
        %    projMatList:double[nDim, nSpDim] - matrices' array of the orthoganal
        %             basis vectors
        %    fGetProjMat - function which creates vector of the projection
        %             matrices
        %        Input:
        %         regular:
        %           projMat:double[nDim, mDim] - matrix of the projection at the
        %             instant of time
        %           timeVec:double[1, nDim] - time interval
        %         optional:
        %            sTime:double[1,1] - instant of time
        %        Output:
        %           projOrthMatArray:double[1, nSpDim] - vector of the projection
        %             matrices
        %           projOrthMatTransArray:double[nSpDim, 1] - transposed vector of
        %             the projection matrices
        % Output:
        %    ellTubeProjRel:smartdb.relation.StaticRelation[1, 1]/
        %        smartdb.relation.DynamicRelation[1, 1]- projected relation
        %    indProj2OrigVec:cell[nDim, 1] - index of the line number from
        %             which is obtained the projection
        %
        % Example:
        %   function example
        %    aMat = [0 1; 0 0]; bMat = eye(2);
        %    SUBounds = struct();
        %    SUBounds.center = {'sin(t)'; 'cos(t)'};
        %    SUBounds.shape = [9 0; 0 2];
        %    sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds);
        %    x0EllObj = ell_unitball(2);
        %    timeVec = [0 10];
        %    dirsMat = [1 0; 0 1]';
        %    rsObj = elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, timeVec);
        %    ellTubeObj = rsObj.getEllTubeRel();
        %    unionEllTube = ...
        %     gras.ellapx.smartdb.rels.EllUnionTube.fromEllTubes(ellTubeObj);
        %    projSpaceList = {[1 0;0 1]};
        %    projType = gras.ellapx.enums.EProjType.Static;
        %    statEllTubeProj = unionEllTube.project(projType,projSpaceList,...
        %       @fGetProjMat);
        %    plObj=smartdb.disp.RelationDataPlotter();
        %    statEllTubeProj.plot(plObj);
        % end
        %
        % function [projOrthMatArray,projOrthMatTransArray]=fGetProjMat(projMat,...
        %     timeVec,varargin)
        %   nTimePoints=length(timeVec);
        %   projOrthMatArray=repmat(projMat,[1,1,nTimePoints]);
        %   projOrthMatTransArray=repmat(projMat.',[1,1,nTimePoints]);
        %  end
        [ellTubeProjRel,indProj2OrigVec]=project(self,varargin)
    end
end

