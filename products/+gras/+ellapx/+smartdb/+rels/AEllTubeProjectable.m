classdef AEllTubeProjectable<handle
    methods (Abstract)
        % PROJECT - computes projection of the relation object onto given time
        %           dependent subspase
        % Input:
        %   regular:
        %       self.
        %       projType: gras.ellapx.enums.EProjType[1,1] -
        %           type of the projection, can be
        %           'Static' and 'DynamicAlongGoodCurve'
        %       projMatList: cell[1,nProj] of double[nSpDim,nDim] - list of
        %           projection matrices, not necessarily orthogonal
        %    fGetProjMat: function_handle[1,1] - function which creates
        %       vector of the projection
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
        %    ellTubeProjRel: gras.ellapx.smartdb.rels.EllTubeProj[1, 1]/
        %        gras.ellapx.smartdb.rels.EllTubeUnionProj[1, 1] -
        %           projected ellipsoidal tube
        %
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
        %    projMatList = {[1 0;0 1]};
        %    projType = gras.ellapx.enums.EProjType.Static;
        %    statEllTubeProj = unionEllTube.project(projType,projMatList,...
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
    methods
        % PROJECTSTATIC - computes a static projection of the relation
        % object onto static subspaces specified by static matrices
        %
        % Input:
        %   regular:
        %       self
        %       projMatList: double[nSpDim,nDim]/cell[1,nProj] 
        %           of double[nSpDim,nDim] - list of
        %               projection matrices, not necessarily orthogonal
        %
        % Output:
        %   ellTubeProjRel: smartdb.relation.StaticRelation[1, 1]/
        %        smartdb.relation.DynamicRelation[1, 1]- projected relation
        %   indProj2OrigVec:cell[nDim, 1] - index of the line number from
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
        %    projMatList = {[1 0;0 1]};
        %    statEllTubeProj = unionEllTube.project(projMatList);
        %    plObj=smartdb.disp.RelationDataPlotter();
        %    statEllTubeProj.plot(plObj);
        % end
        %
        function [ellTubeProjRel,indProj2OrigVec]=projectStatic(self,...
                projMatList)
            if ~iscell(projMatList)
                projMatList={projMatList};
            end
            projectorObj=gras.ellapx.proj.EllTubeStaticSpaceProjector(...
                projMatList);
            %
            [ellTubeProjRel,indProj2OrigVec]=projectorObj.project(...
                self);
        end
    end
end

