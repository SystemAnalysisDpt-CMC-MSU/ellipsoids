classdef EllUnionTube<gras.ellapx.smartdb.rels.TypifiedByFieldCodeRel&...
        gras.ellapx.smartdb.rels.EllTubeBasic&...
        gras.ellapx.smartdb.rels.EllUnionTubeBasic
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
    methods (Access = protected)
        function fieldsList = getNoCatOrCutFieldsList(self)
            ellTubeBasicList = self.getNoCatOrCutFieldsList@...
                gras.ellapx.smartdb.rels.EllTubeBasic;
            fieldsList=[ellTubeBasicList;'ELL_UNION_TIME_DIRECTION';...
                'IS_LS_TOUCH';'IS_LS_TOUCH_OP'];
        end
        function fieldsList = getSFieldsList(self)
            ellTubeBasicList = self.getSFieldsList@...
                gras.ellapx.smartdb.rels.EllTubeBasic;
            fieldsList=[ellTubeBasicList;'IS_LS_TOUCH';...
                'IS_LS_TOUCH_OP'];
        end
        function fieldsList = getTFieldsList(self)
            ellTubeBasicList = self.getTFieldsList@...
                gras.ellapx.smartdb.rels.EllTubeBasic;
            fieldsList=[ellTubeBasicList;'IS_LT_TOUCH_VEC';...
                'IS_LT_TOUCH_OP_VEC'];
        end
        function fieldsList = getScalarFieldsList(self)
            ellTubeBasicList = self.getScalarFieldsList@...
                gras.ellapx.smartdb.rels.EllTubeBasic;
            fieldsList=[ellTubeBasicList;'IS_LS_TOUCH';...
                'IS_LS_TOUCH_OP'];
        end
    end
    methods(Access=protected)
        function checkDataConsistency(self)
            checkDataConsistency@gras.ellapx.smartdb.rels.EllTubeBasic(self);
            nTubes=self.getNTuples();
            timeVecList=self.timeVec;
            timeTouchEndVecList=self.timeTouchEndVec;
            timeTouchOpEndVecList=self.timeTouchOpEndVec;
            isLtTouchVecList=self.isLtTouchVec;
            isLtTouchOpVecList=self.isLtTouchOpVec;
            %
            for iTube=1:nTubes
                startTime=min(timeVecList{iTube});
                endTime=max(timeVecList{iTube});
                check(timeTouchEndVecList{iTube},...
                    isLtTouchVecList{iTube},'');
                check(timeTouchOpEndVecList{iTube},...
                    isLtTouchOpVecList{iTube},'Op');
            end
            %
            function check(timeTouchEndVec,isLtTouchVec,tag)
                import modgen.common.throwerror;
                isOk=all(timeTouchEndVec<=endTime&...
                    timeTouchEndVec>=startTime|...
                    xor(isnan(timeTouchEndVec),isLtTouchVec));
                if ~isOk
                    throwerror('wrongInput',...
                        ['Values of timeTouch%sEndVec are expected to be within ',...
                        '[startTime,endTime] range and consistent ',...
                        'with isLtTouch%Vec'],tag);
                end
            end
        end
        function changeDataPostHook(self)
            self.checkDataConsistency();
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
            %
            if self.getNTuples()>0
                if projType~=EProjType.Static
                    throwerror('wrongInput',...
                        'only projections on Static subspace are supported');
                end
                [projRel,indProj2OrigVec]=...
                    project@gras.ellapx.smartdb.rels.EllTubeBasic(...
                    self,projType,varargin{:});
                projRel.catWith(self.getTuples(indProj2OrigVec),...
                    'duplicateFields','useOriginal');
                ellTubeProjRel=EllUnionTubeStaticProj(projRel);
            else
                ellTubeProjRel=EllUnionTubeStaticProj();
            end
        end
        function self=EllUnionTube(varargin)
            self=self@gras.ellapx.smartdb.rels.TypifiedByFieldCodeRel(...
                varargin{:});
        end
    end
end