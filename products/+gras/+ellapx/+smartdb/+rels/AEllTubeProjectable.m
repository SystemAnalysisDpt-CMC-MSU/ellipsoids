classdef AEllTubeProjectable<handle
    % $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-2015 $
    % $Copyright: Moscow State University,
    %            Faculty of Computational Mathematics and Computer Science,
    %            System Analysis Department 2015 $   
    %
    methods (Abstract)
        % PROJECT - computes projections of ellipsoidal tubes
        %
        % Input:
        %   regular:
        %       self: collection of original (not projected ellipsoidal
        %           tubes)
        %       projType: gras.ellapx.enums.EProjType[1,1] -
        %           type of the projection, can be
        %           'Static' and 'DynamicAlongGoodCurve'
        %       projMatList: cell[1,nProjections] of double[nProjDims,nDims] 
        %           - list of projection matrices, not necessarily orthogonal
        %       fGetProjMat: function_handle[1,1] - function which creates
        %           an array of projection matrices. The function has the
        %           following input and output parameters:
        %               Input:
        %                   regular:
        %                       projMat: double[nProjDims,mDims] - projection 
        %                           matrix at time t_s=sTime (see below)
        %                       timeVec: double[1,nTimePoints] - time
        %                           vector
        %                   optional:
        %                       sTime:double[1,1] - instant of time at
        %                           which projection matrix is specified
        %               Output:
        %                   projOrthMatArray: double[nProjDims,nDims,nTimePoints] 
        %                       - vector of the projection matrices
        %                   projOrthMatTransArray: double[nProjDims,nDims,nTimePoints] 
        %                       - transposed vector of the projection 
        %                       matrices
        % Output:
        %    ellTubeProjRel: gras.ellapx.smartdb.rels.EllTubeProj[1, 1]/
        %        gras.ellapx.smartdb.rels.EllTubeUnionProj[1, 1] -
        %           collection of projected ellipsoidal tubes
        %
        %    indProj2OrigVec: double[nProjTubes,1] - index of the original
        %       tube in "self" collection (see input parameters) from which
        %       the corresponding projected tube is obtained
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
        %
        % $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-2015 $
        % $Copyright: Moscow State University,
        %            Faculty of Computational Mathematics and Computer Science,
        %            System Analysis Department 2015 $    
        %
        [ellTubeProjRel,indProj2OrigVec]=project(self,varargin)
    end
    methods
        % PROJECTSTATIC - computes a static projection of ellipsoidal tubes
        %   onto static subspaces specified by projection matrices
        %
        % Input:
        %   regular:
        %       self: collection of original (not projected ellipsoidal
        %           tubes)
        %       projMatList: double[nProjDims,nDims]/cell[1,nProjections] 
        %           of double[nProjDims,nDims] - list of
        %               projection matrices, not necessarily orthogonal
        %
        % Output:
        %   ellTubeProjRel: smartdb.relation.StaticRelation[1, 1]/
        %        smartdb.relation.DynamicRelation[1, 1]- collection of
        %        projected ellipsoidal tubes
        %
        %    indProj2OrigVec: double[nProjTubes,1] - index of the original
        %       tube in "self" collection (see input parameters) from which
        %       the corresponding projected tube is obtained
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
        % $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-2015 $
        % $Copyright: Moscow State University,
        %            Faculty of Computational Mathematics and Computer Science,
        %            System Analysis Department 2015 $    
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

