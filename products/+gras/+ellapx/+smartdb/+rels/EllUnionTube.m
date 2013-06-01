classdef EllUnionTube<gras.ellapx.smartdb.rels.TypifiedByFieldCodeRel&...
        gras.ellapx.smartdb.rels.EllTubeBasic&...
        gras.ellapx.smartdb.rels.EllUnionTubeBasic
    %TestRelation Summary of this class goes here
    %   Detailed explanation goes here
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
            import import gras.ellapx.smartdb.rels.EllUnionTube;
            import gras.ellapx.enums.EEllUnionTimeDirection;
            import gras.ellapx.enums.EApproxType;
            import modgen.common.throwerror;
            %
            nTubes=ellTubeRel.getNTuples();
            %
            SData=ellTubeRel.getData();
            SData.isLtTouchVec=cell(nTubes,1);
            SData.timeTouchEndVec=cell(nTubes,1);
            %
            SData.isLtTouchOpVec=cell(nTubes,1);
            SData.timeTouchOpEndVec=cell(nTubes,1);
            %
            SData.isLsTouch=false(nTubes,1);
            SData.isLsTouchOp=false(nTubes,1);
            %
            SData.ellUnionTimeDirection=repmat(...
                EEllUnionTimeDirection.Ascending,nTubes,1);
            %
            TOUCH_TOL=1e-14;
            %
            for iTube=1:nTubes
                if SData.approxType(iTube)==EApproxType.External
                    fCalcTouchArea=@calcTouchArea;
                else
                    fCalcTouchArea=@calcNeverTouchArea;
                end
                QArray=SData.QArray{iTube};
                aMat=SData.aMat{iTube};
                timeVec=SData.timeVec{iTube};
                indSTime=SData.indSTime(iTube);
                %
                [SData.isLtTouchVec{iTube},SData.isLsTouch(iTube),...
                    SData.timeTouchEndVec{iTube}]=fCalcTouchArea(...
                    SData.xTouchCurveMat{iTube});
                %
                [SData.isLtTouchOpVec{iTube},SData.isLsTouchOp(iTube),...
                    SData.timeTouchOpEndVec{iTube}]=fCalcTouchArea(...
                    SData.xTouchOpCurveMat{iTube});
                %
            end
            ellUnionTubeRel=EllUnionTube(SData);
            %
            function [isLtTouchVec,isLsTouch,timeTouchEndVec]=...
                    calcNeverTouchArea(xTouchCurveMat)
                nTimes=length(timeVec);
                isLtTouchVec=false(1,nTimes);
                isLsTouch=false;
                timeTouchEndVec=nan(1,nTimes);
            end
            function [isLtTouchVec,isLsTouch,timeTouchEndVec]=...
                    calcTouchArea(xTouchCurveMat)
                nTimes=length(timeVec);
                isTouchCandidateVec=true(1,nTimes);
                indTimeTouchEndVec=nan(1,nTimes);
                isLtTouchVec=false(1,nTimes);
                %
                valueFuncVec=nan(1,nTimes);
                %
                for iTime=1:nTimes
                    indCandidateVec=find(isTouchCandidateVec);
                    nCandidates=length(indCandidateVec);
                    %
                    normVec=gras.gen.SquareMatVector.lrDivideVec(...
                        QArray(:,:,iTime),...
                        xTouchCurveMat(:,isTouchCandidateVec)-...
                        aMat(:,repmat(iTime,1,nCandidates)));
                    normVec=min(valueFuncVec(isTouchCandidateVec),normVec);
                    valueFuncVec(isTouchCandidateVec)=normVec;
                    isnTouchSubVec=normVec<1-TOUCH_TOL;
                    %
                    isTouchVec=isTouchCandidateVec;
                    isTouchVec(indCandidateVec(isnTouchSubVec))=false;
                    indTimeTouchEndVec(isTouchVec)=iTime;
                    %
                    isLtTouchVec(iTime)=isTouchVec(iTime);
                    isTouchCandidateVec=isTouchVec;
                end
                isLsTouch=isLtTouchVec(indSTime);
                isEndBeforeStartVec=indTimeTouchEndVec<(1:nTimes);
                indTimeTouchEndVec(isEndBeforeStartVec)=nan;
                %
                isnNanTimeTouchEndVec=~isnan(indTimeTouchEndVec);
                timeTouchEndVec=nan(1,nTimes);
                timeTouchEndVec(isnNanTimeTouchEndVec)=...
                    timeVec(indTimeTouchEndVec(isnNanTimeTouchEndVec));
            end
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