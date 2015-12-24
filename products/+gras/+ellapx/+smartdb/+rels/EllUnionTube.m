classdef EllUnionTube<gras.ellapx.smartdb.rels.ATypifiedAdjustedRel&...
        gras.ellapx.smartdb.rels.EllTubeBasic&...        
        gras.ellapx.smartdb.rels.EllUnionTubeBasic&...
        gras.ellapx.smartdb.rels.AEllTubeProjectable
    % EllUionTube - collection of ellipsoidal tubes by the instant of
    %               time i.e. union of E[\tau] for all \tau from [t_0,t]
    %               (for reachability problem) or from [t,T] for
    %               solvability problem, where E[\tau] is ordinary 
    %               ellipsoidal tube
    % 
    % Public properties:
    %       - in addition to the fields of gras.ellapx.smartdb.rels.UnionTube
    %       this class has the following public fields
    %   isLsTouchOp: - same as isLsTouch (see EllTube properties 
    %       description) but for -l(t_s) i.e. opposite direction    
    %   isLtTouchOpVec: - same as isLtTouchVec (see EllTube properties 
    %       description) but for -l(t) i.e. for the opposite direction    
    %   ellUnionTimeDirection: 
    %       gras.ellapx.enums.EEllUnionTimeDirection[nTubes,1] - direction
    %       along which ellipsoidal tube cuts E[t] are united, it can have
    %       the following values:
    %           "Ascending" for reachability problems
    %           "Descending" for solvability problems
    %   timeTouchEndVec: cell[nTubes,1] of double[1,nTimePoints] - list of
    %       last touch time vectors for each tube. Each element of the touch 
    %       time vector contains the last time t*(t) preceeding 
    %       (or following depending on the value of ellUnionTimeDirection
    %       field) time t when E[t] touched reachability domain along 
    %       l(t*(t))
    %   
    %   timeTouchOpEndVec: - same as timeTouchEndVec but for the opposite
    %       direction
    %
    % $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-2015 $
    % $Copyright: Moscow State University,
    %            Faculty of Computational Mathematics and Computer Science,
    %            System Analysis Department 2015 $  
    %
    methods (Access=protected,Static,Hidden)
        function outObj=loadobj(inpObj)
            import gras.ellapx.smartdb.rels.ATypifiedAdjustedRel;
            outObj=ATypifiedAdjustedRel.loadObjViaConstructor(...
                mfilename('class'),inpObj);
        end
    end
    %
    methods 
        function fieldsList = getNoCatOrCutFieldsList(self)
            import  gras.ellapx.smartdb.F;
            fieldsList = [getNoCatOrCutFieldsList@gras.ellapx.smartdb.rels.EllTubeBasic(self);
                getNoCatOrCutFieldsList@gras.ellapx.smartdb.rels.EllUnionTubeBasic(self)];
        end        
    end
    methods (Access = protected)
        function fieldsList = getSFieldsList(self)
            import  gras.ellapx.smartdb.F;
            fieldsList = [getSFieldsList@gras.ellapx.smartdb.rels.EllTubeBasic(self);
                getSFieldsList@gras.ellapx.smartdb.rels.EllUnionTubeBasic(self)];
        end
        function fieldsList = getTFieldsList(self)
            import  gras.ellapx.smartdb.F;
            fieldsList = [getTFieldsList@gras.ellapx.smartdb.rels.EllTubeBasic(self);
                getTFieldsList@gras.ellapx.smartdb.rels.EllUnionTubeBasic(self)];
        end
        function fieldsList = getScalarFieldsList(self)
            import  gras.ellapx.smartdb.F;
            fieldsList = [getScalarFieldsList@gras.ellapx.smartdb.rels.EllTubeBasic(self);
                getScalarFieldsList@gras.ellapx.smartdb.rels.EllUnionTubeBasic(self)];
        end
        function [valFieldNameList,touchFieldNameList]=...
                getPossibleNanFieldList(self)
            [valFieldNameList,touchFieldNameList]=...
                getPossibleNanFieldList@gras.ellapx.smartdb.rels.EllUnionTubeBasic(self);
        end     
        function fieldsList=getTouchCurveDependencyFieldList(self)
            fieldsList = [...
                getTouchCurveDependencyFieldList@gras.ellapx.smartdb.rels.EllTubeBasic(self),...
                getTouchCurveDependencyFieldList@gras.ellapx.smartdb.rels.EllUnionTubeBasic(self)];
        end           
        function checkDataConsistency(self)
            checkDataConsistency@gras.ellapx.smartdb.rels.EllTubeBasic(self);
            checkDataConsistency@gras.ellapx.smartdb.rels.EllUnionTubeBasic(self);
        end
        function changeDataPostHook(self)
            self.checkDataConsistency();
        end
        function SData = getInterpInternal(self, newTimeVec)
            SData = struct;
            import gras.ellapx.smartdb.F;
            if (~isempty(newTimeVec))
                SData = getInterpInternal@...
                    gras.ellapx.smartdb.rels.EllTubeBasic(self,newTimeVec);
                tEllTube = gras.ellapx.smartdb.rels.EllTube(...
                    ).createInstance(SData);
                SData = self.fromEllTubes(tEllTube).getData();
            end
            %
        end
    end
    methods (Static)
        function ellUnionTubeRel=fromEllTubes(ellTubeRel)
            % FROMELLTUBES - returns union of the ellipsoidal tubes on time
            %
            % Input:
            %    ellTubeRel: smartdb.relation.StaticRelation[1, 1]/
            %       smartdb.relation.DynamicRelation[1, 1] - relation
            %       object
            %
            % Output:
            % ellUnionTubeRel: ellapx.smartdb.rel.EllUnionTube - union of the 
            %             ellipsoidal tubes
            %       
            import gras.ellapx.smartdb.rels.EllUnionTube;
            import gras.ellapx.smartdb.rels.EllUnionTubeBasic;
            import gras.ellapx.enums.EEllUnionTimeDirection;
            import gras.ellapx.enums.EApproxType;
            import modgen.common.throwerror;
            %            
            ellUnionTubeRel=EllUnionTube();
            ellUnionTubeRel.setDataFromEllTubesInternal(ellTubeRel);
        end
    end
    methods 
        function [ellTubeProjRel,indProj2OrigVec]=project(self,projType,...
                varargin)
            import gras.ellapx.smartdb.rels.EllUnionTubeStaticProj;
            import gras.ellapx.smartdb.rels.EllTubeBasic;
            import gras.ellapx.enums.EProjType;
            import modgen.common.throwerror;
            import gras.ellapx.smartdb.F;
            %
            if self.getNTuples()>0
                if projType~=EProjType.Static
                    throwerror('wrongInput',...
                        'only projections on Static subspace are supported');
                end
                %store original values of IS_LT_TOUCH_VEC and F.IS_LT_TOUCH_OP_VEC
                [projRel,indProj2OrigVec]=...
                    self.projectInternal(projType,varargin{:});
                %
                isLtTouchVecList=self.(F.IS_LT_TOUCH_VEC)(indProj2OrigVec);
                isLtTouchOpVecList=self.(F.IS_LT_TOUCH_OP_VEC)(indProj2OrigVec);
                %
                projRel.catWith(self.getTuples(indProj2OrigVec),...
                    'duplicateFields','useOriginal');  
                [~,indTimeTouchEndVecList]=cellfun(@ismember,...
                    projRel.(F.TIME_TOUCH_END_VEC),projRel.(F.TIME_VEC),...
                    'UniformOutput',false);
                [~,indTimeTouchOpEndVecList]=cellfun(@ismember,...
                    projRel.(F.TIME_TOUCH_OP_END_VEC),projRel.(F.TIME_VEC),...
                    'UniformOutput',false);
                %
                isTouchCandidateCVec=cellfun(@calcTouchCandidateVec,...
                    projRel.(F.LT_GOOD_DIR_NORM_VEC),...
                    indTimeTouchEndVecList,...
                    num2cell(projRel.(F.ABS_TOLERANCE)),'UniformOutput',false);
                %
                isTouchCandidateOpCVec=cellfun(@calcTouchCandidateVec,...
                    projRel.(F.LT_GOOD_DIR_NORM_VEC),...
                    indTimeTouchOpEndVecList,...
                    num2cell(projRel.(F.ABS_TOLERANCE)),'UniformOutput',false);                
                %
                projRel.(F.IS_LT_TOUCH_OP_VEC)=cellfun(@and,...
                    isTouchCandidateOpCVec,...
                    isLtTouchOpVecList,'UniformOutput',false);
                %
                projRel.(F.IS_LT_TOUCH_VEC)=cellfun(@and,...
                    isTouchCandidateCVec,...
                    isLtTouchVecList,'UniformOutput',false);
                %
                projRel.(F.IS_LS_TOUCH)=cellfun(@(x,y)x(y),...
                    projRel.(F.IS_LT_TOUCH_VEC),num2cell(projRel.indSTime));
                %
                projRel.(F.IS_LS_TOUCH_OP)=cellfun(@(x,y)x(y),...
                    projRel.(F.IS_LT_TOUCH_OP_VEC),num2cell(projRel.indSTime));
                %
                projRel.(F.TIME_TOUCH_END_VEC)=cellfun(@assignNans,...
                    projRel.(F.TIME_TOUCH_END_VEC), projRel.(F.IS_LT_TOUCH_VEC),...
                    'UniformOutput',false);
                projRel.(F.TIME_TOUCH_OP_END_VEC)=cellfun(@assignNans,...
                    projRel.(F.TIME_TOUCH_OP_END_VEC),projRel.(F.IS_LT_TOUCH_OP_VEC),...
                    'UniformOutput',false);     
                %
                projRel.(F.X_TOUCH_CURVE_MAT)=cellfun(@assignNans,...
                    projRel.(F.X_TOUCH_CURVE_MAT), projRel.(F.IS_LT_TOUCH_VEC),...
                    'UniformOutput',false);
                projRel.(F.X_TOUCH_OP_CURVE_MAT)=cellfun(@assignNans,...
                    projRel.(F.X_TOUCH_OP_CURVE_MAT),projRel.(F.IS_LT_TOUCH_OP_VEC),...
                    'UniformOutput',false);
                %
                projRel.(F.XS_TOUCH_VEC)=cellfun(@(x,y)x(:,y),...
                    projRel.(F.X_TOUCH_CURVE_MAT),...
                    num2cell(projRel.indSTime),'UniformOutput',false);                
                projRel.(F.XS_TOUCH_OP_VEC)=cellfun(@(x,y)x(:,y),...
                    projRel.(F.X_TOUCH_OP_CURVE_MAT),...
                    num2cell(projRel.indSTime),'UniformOutput',false);
                %
                ellTubeProjRel=EllUnionTubeStaticProj(projRel);
            else
                ellTubeProjRel=EllUnionTubeStaticProj();
                indProj2OrigVec=zeros(0,1);
            end
            function isTouchVec=calcTouchCandidateVec(normVec,indTimeVec,absTol)
                isTouchVec=false(size(normVec));
                isNormOkVec=normVec>absTol;
                isnZeroIndTime=indTimeVec>0;
                isTouchVec(isnZeroIndTime)=isNormOkVec(indTimeVec(isnZeroIndTime));
            end
            function x=assignNans(x,y)
                x(:,~y)=nan;
            end
        end
        function self=EllUnionTube(varargin)
            self=self@gras.ellapx.smartdb.rels.ATypifiedAdjustedRel(...
                varargin{:});
        end
    end
end