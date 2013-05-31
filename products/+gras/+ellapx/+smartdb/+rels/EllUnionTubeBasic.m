classdef EllUnionTubeBasic<handle
    %TestRelation Summary of this class goes here
    %   Detailed explanation goes here
    properties (Constant,Hidden)
        FCODE_ELL_UNION_TIME_DIRECTION
        %
        FCODE_IS_LS_TOUCH
        FCODE_IS_LS_TOUCH_OP
        %
        FCODE_IS_LT_TOUCH_VEC
        FCODE_IS_LT_TOUCH_OP_VEC
        %
        FCODE_TIME_TOUCH_END_VEC
        FCODE_TIME_TOUCH_OP_END_VEC        
    end
    methods(Access=protected)
        setDataInternal(~);
    end
    methods (Access = protected)
        function self = setDataFromEllTubesInternal(self, ellTubeRel)
            import gras.ellapx.smartdb.rels.EllUnionTube;
            import gras.ellapx.smartdb.rels.EllUnionTubeBasic;
            import gras.ellapx.enums.EEllUnionTimeDirection;
            import gras.ellapx.enums.EApproxType;
            import modgen.common.throwerror;
            
            nTubes=ellTubeRel.getNTuples();
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
            self.setDataInternal(SData);
            %
            function [isLtTouchVec,isLsTouch,timeTouchEndVec]=...
                    calcNeverTouchArea(~)
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
 end