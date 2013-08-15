classdef EllUnionTubeBasic<handle
    %TestRelation Summary of this class goes here
    %   Detailed explanation goes here
    properties (Constant,Hidden)
        FCODE_ELL_UNION_TIME_DIRECTION
        %
        FCODE_TIME_TOUCH_END_VEC
        FCODE_TIME_TOUCH_OP_END_VEC   
        FCODE_IS_LS_TOUCH_OP        
        FCODE_IS_LT_TOUCH_OP_VEC   
    end
    methods(Access=protected)
        setDataInternal(~);
    end
   methods 
        function fieldsList = getNoCatOrCutFieldsList(~)
            import  gras.ellapx.smartdb.F;
            fieldsList=F().getNameList({'ELL_UNION_TIME_DIRECTION';...
                'IS_LS_TOUCH_OP'});
        end        
    end
    methods(Access=protected)
        function dependencyFieldList=getTouchCurveDependencyFieldList(~)
            import  gras.ellapx.smartdb.F;
            dependencyFieldList=F().getNameList({'APPROX_TYPE'});
        end        
        function fieldsList = getSFieldsList(~)
            import gras.ellapx.smartdb.F;
            fieldsList = F().getNameList({'IS_LS_TOUCH_OP'});
        end
        function fieldsList = getTFieldsList(~)
            import  gras.ellapx.smartdb.F;
            fieldsList = F().getNameList({'IS_LT_TOUCH_OP_VEC'});
        end
        function fieldsList = getScalarFieldsList(~)
            import  gras.ellapx.smartdb.F;
            fieldsList = F().getNameList({'IS_LS_TOUCH_OP'});
        end
        function [valFieldNameList,touchFieldNameList]=...
                getPossibleNanFieldList(~)
            valFieldNameList={'xsTouchVec','xTouchCurveMat',...
                'xsTouchOpVec','xTouchOpCurveMat','timeTouchEndVec',...
                'timeTouchOpEndVec'};
            touchFieldNameList={'isLsTouch','isLtTouchVec',...
                'isLsTouchOp','isLtTouchOpVec','isLtTouchVec',...
                'isLtTouchOpVec'};
        end
        function checkDataConsistency(self)
            %
            %
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
            checkTAndS('isLtTouchVec','timeTouchEndVec');
            checkTAndS('isLtTouchOpVec','timeTouchOpEndVec');            
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
            function checkTAndS(fieldIsLtTouch,fieldTimeTouchEnd)
                if self.getNTuples()>0
                    cellfun(@checkOneTAndS,self.(fieldIsLtTouch),...
                        self.(fieldTimeTouchEnd));
                end
                function checkOneTAndS(isLtTouchVec,timeTouchEndVec)
                    import modgen.common.throwerror;
                    timeTouchNotNanVec=timeTouchEndVec(isLtTouchVec);
                    isOk=~any(isnan(timeTouchNotNanVec));
                    if ~isOk
                        throwerror('wrongInput',...
                            ['field %s have NaNs at touch moments ',...
                            'specified by field %s'],fieldTimeTouchEnd,...
                            fieldIsLtTouch);
                    end
                    %
                    isOk=all(isnan(timeTouchEndVec(~isLtTouchVec)));
                    if ~isOk
                        throwerror('wrongInput',...
                            ['field %s doesn''t have NaNs for all non-touch',...
                            ' moments specified by field %s'],...
                            fieldTimeTouchEnd,fieldIsLtTouch);
                    end
                    if any(isLtTouchVec)
                        isNanVec=~isLtTouchVec;
                        indCumVec=cumsum(isNanVec);
                        indNotUniqueGroupVec=indCumVec(isLtTouchVec);
                        [~,~,indGroupVec]=unique(indNotUniqueGroupVec);
                        isOk=all(accumarray(indGroupVec.',timeTouchNotNanVec.',[],...
                            @(x)all(diff(x)>=0)));
                        if ~isOk
                            throwerror('wrongInput',...
                                'field %s contains non-monotone values',...
                                fieldTimeTouchEnd);
                        end
                        timeMinVec=(accumarray(indGroupVec.',timeTouchNotNanVec.',[],...
                            @(x)x(1)));
                        timeMaxVec=(accumarray(indGroupVec.',timeTouchNotNanVec.',[],...
                            @(x)x(end)));
                        isOk=all(timeMinVec(2:end)>timeMaxVec(1:end-1));
                        if ~isOk
                            throwerror('wrongInput',...
                                ['field %s is expected to contain ',...
                                'strongly-monotone values across ',...
                                'different touch groups'],...
                                fieldTimeTouchEnd)
                        end
                    end
                end
            end
        end
        function self = setDataFromEllTubesInternal(self, ellTubeRel)
            import gras.ellapx.smartdb.rels.EllUnionTube;
            import gras.ellapx.smartdb.rels.EllUnionTubeBasic;
            import gras.ellapx.enums.EEllUnionTimeDirection;
            import gras.ellapx.enums.EApproxType;
            import modgen.common.throwerror;
            
            nTubes=ellTubeRel.getNTuples();
            SData=ellTubeRel.getData();
            SData.timeTouchEndVec=cell(nTubes,1);
            %
            SData.isLtTouchOpVec=cell(nTubes,1);
            SData.timeTouchOpEndVec=cell(nTubes,1);
            %
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
                isOrigLtTouchVec=SData.isLtTouchVec{iTube};
                [SData.isLtTouchVec{iTube},SData.isLsTouch(iTube),...
                    SData.xTouchCurveMat{iTube},SData.xsTouchVec{iTube},...
                    SData.timeTouchEndVec{iTube}]=fCalcTouchArea(...
                    SData.xTouchCurveMat{iTube},isOrigLtTouchVec);
                %
                [SData.isLtTouchOpVec{iTube},SData.isLsTouchOp(iTube),...
                    SData.xTouchOpCurveMat{iTube},SData.xsTouchOpVec{iTube},...
                    SData.timeTouchOpEndVec{iTube}]=fCalcTouchArea(...
                    SData.xTouchOpCurveMat{iTube},isOrigLtTouchVec);                
               %
            end
            self.setDataInternal(SData);
            %
            function [isLtTouchVec,isLsTouch,...
                    xTouchCurveMat,xsTouchVec,...
                    timeTouchEndVec]=...
                    calcNeverTouchArea(xTouchCurveMat,~)
                nTimes=length(timeVec);                
                isLtTouchVec=false(1,nTimes);                
                isLsTouch=false;
                timeTouchEndVec=nan(1,nTimes);
                xTouchCurveMat=nan(size(xTouchCurveMat));
                xsTouchVec=xTouchCurveMat(:,indSTime);
            end
            %
            function [isLtTouchVec,isLsTouch,...
                    xTouchCurveMat,xsTouchVec,...                    
                    timeTouchEndVec]=...
                    calcTouchArea(xTouchCurveMat,isLtTouchVec)
                nTimes=length(timeVec);                
                isTouchCandidateVec=isLtTouchVec;
                indTimeTouchEndVec=nan(1,nTimes);
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
                    isTouchCandidateVec(iTime)=false;
                end
                isLsTouch=isLtTouchVec(indSTime);                
                isEndBeforeStartVec=indTimeTouchEndVec<(1:nTimes);
                indTimeTouchEndVec(isEndBeforeStartVec)=nan;
                %
                isnNanTimeTouchEndVec=~isnan(indTimeTouchEndVec);
                timeTouchEndVec=nan(1,nTimes);                                
                timeTouchEndVec(isnNanTimeTouchEndVec)=...
                    timeVec(indTimeTouchEndVec(isnNanTimeTouchEndVec));
                xTouchCurveMat(:,~isLtTouchVec)=nan;
                xsTouchVec=xTouchCurveMat(:,indSTime);
            end
        end
    end
 end