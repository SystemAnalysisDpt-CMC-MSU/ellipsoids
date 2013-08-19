classdef EllUnionTube<gras.ellapx.smartdb.rels.ATypifiedAdjustedRel&...
        gras.ellapx.smartdb.rels.EllTubeBasic&...        
        gras.ellapx.smartdb.rels.EllUnionTubeBasic&...
        gras.ellapx.smartdb.rels.AEllTubeProjectable
    % EllUionTube - class which keeps ellipsoidal tubes by the instant of
    %               time
    % 
    % Fields:
    %   QArray:cell[1, nElem] - Array of ellipsoid matrices                              
    %   aMat:cell[1, nElem] - Array of ellipsoid centers                               
    %   scaleFactor:double[1, 1] - Tube scale factor                                        
    %   MArray:cell[1, nElem] - Array of regularization ellipsoid matrices                
    %   dim :double[1, 1] - Dimensionality                                          
    %   sTime:double[1, 1] - Time s                                                   
    %   approxSchemaName:cell[1,] - Name                                                      
    %   approxSchemaDescr:cell[1,] - Description                                               
    %   approxType:gras.ellapx.enums.EApproxType - Type of approximation 
    %                 (external, internal, not defined 
    %   timeVec:cell[1, m] - Time vector                                             
    %   calcPrecision:double[1, 1] - Calculation precision                                    
    %   indSTime:double[1, 1]  - index of sTime within timeVec                             
    %   ltGoodDirMat:cell[1, nElem] - Good direction curve                                     
    %   lsGoodDirVec:cell[1, nElem] - Good direction at time s                                  
    %   ltGoodDirNormVec:cell[1, nElem] - Norm of good direction curve                              
    %   lsGoodDirNorm:double[1, 1] - Norm of good direction at time s                         
    %   xTouchCurveMat:cell[1, nElem] - Touch point curve for good 
    %                                   direction                     
    %   xTouchOpCurveMat:cell[1, nElem] - Touch point curve for direction 
    %                                     opposite to good direction
    %   xsTouchVec:cell[1, nElem]  - Touch point at time s                                    
    %   xsTouchOpVec :cell[1, nElem] - Touch point at time s  
    %   ellUnionTimeDirection:gras.ellapx.enums.EEllUnionTimeDirection - 
    %                      Direction in time along which union is performed          
    %   isLsTouch:logical[1, 1] - Indicates whether a touch takes place 
    %                             along LS           
    %   isLsTouchOp:logical[1, 1] - Indicates whether a touch takes place 
    %                               along LS opposite  
    %   isLtTouchVec:cell[1, nElem] - Indicates whether a touch takes place 
    %                                 along LT         
    %   isLtTouchOpVec:cell[1, nElem] - Indicates whether a touch takes 
    %                                   place along LT opposite  
    %   timeTouchEndVec:cell[1, nElem] - Touch point curve for good 
    %                                    direction                     
    %   timeTouchOpEndVec:cell[1, nElem] - Touch point curve for good 
    %                                      direction
    %
    % TODO: correct description of the fields in 
    %     gras.ellapx.smartdb.rels.EllUnionTube
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
                    num2cell(projRel.(F.CALC_PRECISION)),'UniformOutput',false);
                %
                isTouchCandidateOpCVec=cellfun(@calcTouchCandidateVec,...
                    projRel.(F.LT_GOOD_DIR_NORM_VEC),...
                    indTimeTouchOpEndVecList,...
                    num2cell(projRel.(F.CALC_PRECISION)),'UniformOutput',false);                
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