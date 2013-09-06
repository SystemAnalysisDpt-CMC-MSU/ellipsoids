classdef EllTubeTouchCurveBasic<handle
    %TestRelation Summary of this class goes here
    %   Detailed explanation goes here
    properties (Constant,Hidden)
        FCODE_DIM
        FCODE_S_TIME
        FCODE_APPROX_SCHEMA_NAME
        FCODE_APPROX_SCHEMA_DESCR
        FCODE_APPROX_TYPE
        FCODE_TIME_VEC
        FCODE_CALC_PRECISION
        FCODE_IND_S_TIME
        FCODE_LT_GOOD_DIR_MAT
        FCODE_LS_GOOD_DIR_VEC
        FCODE_LT_GOOD_DIR_NORM_VEC
        FCODE_LS_GOOD_DIR_NORM
        FCODE_X_TOUCH_CURVE_MAT
        FCODE_X_TOUCH_OP_CURVE_MAT
        FCODE_XS_TOUCH_VEC
        FCODE_XS_TOUCH_OP_VEC
        FCODE_IS_LS_TOUCH
        FCODE_IS_LT_TOUCH_VEC
    end
    properties (Constant,Hidden, GetAccess=protected)
        N_GOOD_DIR_DISP_DIGITS=5;
        GOOD_DIR_DISP_TOL=1e-10;
    end
    methods (Access=protected,Sealed)
        function checkSVsTConsistency(~,lsList,ltList,indList,...
                lsName,ltName,fCheck)
            import modgen.common.throwerror;
            if ~isempty(indList)
                isOkVec=cellfun(fCheck,lsList,ltList,indList);
                if ~all(isOkVec)
                    throwerror('wrongInput',['tuples with indices %s ',...
                        'have inconsistent %s and %s'],...
                        mat2str(find(~isOkVec)),lsName,ltName);
                end
            end
        end
        %
        function checkForNan(self,valFieldName,touchFieldName)
            valMat=self.(valFieldName);
            isTouchVec=self.(touchFieldName);
            if islogical(isTouchVec)
                isTouchVec=num2cell(isTouchVec);
            end
            cellfun(@checkForNanTuple,valMat,isTouchVec);
            function checkForNanTuple(valMat,isTouchVec)
                import modgen.common.throwerror;
                expNotNanMat=valMat(:,isTouchVec);
                if any(isnan(expNotNanMat(:)))
                    throwerror('wrongInput',...
                        'field %s contains NaNs for touch time moments',...
                        valFieldName);
                end
                expNanMat=valMat(:,~isTouchVec);
                if ~all(isnan(expNanMat(:)))
                    throwerror('wrongInput',...
                        ['field %s is expected to contain NaNs for ',...
                        'non-touch time moments'],valFieldName);
                end
            end
        end
    end
    methods (Access=protected,Abstract)
        dependencyFieldList=getTouchCurveDependencyFieldList(~)
    end
    methods (Access=protected)
        %
        function strVal=goodDirProp2Str(~,lsGoodDirOrigVec,sTime)
            import gras.ellapx.smartdb.rels.EllTubeTouchCurveProjBasic;
            nGoodDirDispDigits=EllTubeTouchCurveProjBasic.N_GOOD_DIR_DISP_DIGITS;
            goodDirDispTol=EllTubeTouchCurveProjBasic.GOOD_DIR_DISP_TOL;
            lsGoodDirOrigVec(abs(lsGoodDirOrigVec)<goodDirDispTol)=0;
            strVal=['lsGoodDirVec=',...
                mat2str(lsGoodDirOrigVec,nGoodDirDispDigits),',sTime=',...
                num2str(sTime)];
        end
        %
        function checkFieldList=getTouchCurveDependencyCheckedFieldList(~)
            checkFieldList={'xTouchCurveMat','xTouchOpCurveMat',...
                'xsTouchVec','xsTouchOpVec'};
        end
        function depFieldList=getProblemDependencyFieldList(~)
            depFieldList={'MArray'};
        end
        function fCheckFieldTransfList=getTouchCurveDependencyCheckTransFuncList(~)
            fCheckFieldTransfList={...
                @(fieldVal,scaleFactor,aMat,indSTime)(fieldVal-aMat)./scaleFactor,...
                @(fieldVal,scaleFactor,aMat,indSTime)(fieldVal-aMat)./scaleFactor,...
                @(fieldVal,scaleFactor,aMat,indSTime)(fieldVal-aMat(:,indSTime))./scaleFactor,...
                @(fieldVal,scaleFactor,aMat,indSTime)(fieldVal-aMat(:,indSTime))./scaleFactor};
        end
        function fieldNameList=getProjectionDependencyFieldList(~)
            fieldNameList={'timeVec','sTime','dim','indSTime'};
        end
        function [valFieldNameList,touchFieldNameList]=...
                getPossibleNanFieldList(~)
            valFieldNameList={'xsTouchVec','xTouchCurveMat',...
                'xsTouchOpVec','xTouchOpCurveMat'};
            touchFieldNameList={'isLsTouch','isLtTouchVec','isLsTouch',...
                'isLtTouchVec'};
        end
        function checkDataConsistency(self)
            import modgen.common.throwerror;
            import gras.gen.SquareMatVector;
            import modgen.common.num2cell;
            TS_CHECK_TOL=1e-14;
            calcPrecList=num2cell(self.calcPrecision);
            %
            [valueFieldNameList,touchFieldNameList]=...
                self.getPossibleNanFieldList();
            %
            nValFields=length(valueFieldNameList);
            for iValField=1:nValFields
                self.checkForNan(valueFieldNameList{iValField},...
                    touchFieldNameList{iValField});
            end
            %
            %% check all numeric fields for NaNs
            fieldNameList=setdiff(self.getFieldNameList(),valueFieldNameList);
            %
            nFields=length(fieldNameList);
            for iField=1:nFields
                %
                fieldName=fieldNameList{iField};
                fieldValArr=self.(fieldName);
                if isnumeric(fieldValArr)&&any(isnan(fieldValArr(:)))||...
                        iscell(fieldValArr)&&any(cellfun(@(x)isnumeric(x)&&...
                        any(isnan(x(:))),fieldValArr))
                    throwerror('wrongInput',...
                        'field %s contains NaN values',fieldName);
                end
            end
            %% Check ltGoodDirNormVec >=calcPrecision
            isNormLtPositiveVec=...
                cellfun(@(x,y,z)all(x(y)>=z)&&all(x(~y)>=0),...
                self.ltGoodDirNormVec,self.isLtTouchVec,calcPrecList);
            %
            if ~all(isNormLtPositiveVec)
                throwerror('wrongInput',...
                    ['ltGoodDirNormVec is expected to ',...
                    'contain values higher than calcPrecision']);
            end
            %% Check that lsGoodDirNorm >=calcPrecision
            if ~(all(self.lsGoodDirNorm(self.isLsTouch)>...
                    self.calcPrecision(self.isLsTouch))&&...
                    all(self.lsGoodDirNorm(~self.isLsTouch)>=0))
                throwerror('wrongInput',...
                    ['lsGoodDirNorm is expected to ',...
                    'be higher than calcPrecision']);
            end
            %
            %% Check that lsGoodDirVec has norm equal to one
            isNormLsEqualsToOneVec=cellfun(...
                @(x)all(abs(sum(x.*x)-1)<=TS_CHECK_TOL),...
                self.lsGoodDirVec(self.isLsTouch));
            if ~all(isNormLsEqualsToOneVec)
                throwerror('wrongInput',...
                    'failed check for lsGoodDirVec and lsGoodDirNorm');
            end
            %% Check that all vectors in ltGoodDirMat have norm equal to one
            isNormLtEqualsToOneVec=...
                cellfun(...
                @(x,y)all(abs(sum(x(:,y).*x(:,y),1)-1)<=TS_CHECK_TOL),...
                self.ltGoodDirMat,self.isLtTouchVec);
            if ~all(isNormLtEqualsToOneVec)
                throwerror('wrongInput',...
                    'failed check for ltGoodDirMat and lsGoodDirNormVec');
            end
            %% Check for consistency between ls and lt fields
            %
            fCheck=@(x,y,z)((all(isnan(x))&&all(isnan(y(:,z))))||...
                (max(abs(x-y(:,z)))<=TS_CHECK_TOL));
            %
            indSTimeList=num2cell(self.indSTime);
            %
            self.checkSVsTConsistency(self.lsGoodDirVec,...
                self.ltGoodDirMat,indSTimeList,'lsGoodDirVec',...
                'ltGoodDirMat',fCheck);
            self.checkSVsTConsistency(num2cell(self.lsGoodDirNorm),...
                self.ltGoodDirNormVec,indSTimeList,'lsGoodDirNorm',...
                'ltGoodDirNormVec',fCheck);
            %
            self.checkSVsTConsistency(self.xsTouchVec,...
                self.xTouchCurveMat,indSTimeList,'xsTouchVec',...
                'xTouchCurveMat',fCheck);
            self.checkSVsTConsistency(self.xsTouchOpVec,...
                self.xTouchOpCurveMat,indSTimeList,'xsOpTouchVec',...
                'xTouchOpCurveMat',fCheck);
            %% Check that touch curve depends only on sTime and lsGoodDirVec
            rel=smartdb.relations.DynamicRelation(self);
            self.checkTouchCurveIndependence(rel);
        end
    end
    methods (Access=private)
        function checkTouchCurveIndependence(self,rel)
            import modgen.common.absrelcompare;
            %
            dependencyFieldList=self.getTouchCurveDependencyFieldList;
            fCheckFieldTransfList=self.getTouchCurveDependencyCheckTransFuncList();
            checkFieldList=self.getTouchCurveDependencyCheckedFieldList;
            nCheckedFields=length(checkFieldList);
            for iField=1:nCheckedFields
                fieldName=checkFieldList{iField};
                fTransf=fCheckFieldTransfList{iField};
                rel.setField(fieldName,cellfun(fTransf,rel.(fieldName),...
                    num2cell(rel.scaleFactor),rel.aMat,...
                    num2cell(rel.indSTime),'UniformOutput',false),...
                    'inferIsNull',false);
            end
            %
            rel.groupBy(dependencyFieldList);
            nFields=length(checkFieldList);
            nTuples=rel.getNTuples();
            if nTuples>0
                for iField=1:nFields
                    fieldName=checkFieldList{iField};
                    valList=rel.(fieldName);
                    for iTuple=1:nTuples
                        nVals=length(valList{iTuple});
                        tolVec=rel.calcPrecision{iTuple};
                        if nVals>0
                            valSizeVec=size(valList{iTuple}{1});
                            for iVal=2:nVals
                                isOk=isequal(valSizeVec,...
                                    size(valList{iTuple}{iVal}));
                                if ~isOk
                                    throwError('size',fieldName);
                                end
                                %
                                expTol=(tolVec(1)+tolVec(iVal));
                                %
                                isnNanArr=~isnan(valList{iTuple}{1});
                                if any(isnNanArr)
                                    [isOk, actAbsTol, isRelTolUsed, ...
                                        actRelTol] = absrelcompare(...
                                        valList{iTuple}{1}(isnNanArr), ...
                                        valList{iTuple}{iVal}(isnNanArr), expTol, ...
                                        expTol, @vecArrNorm);
                                    if ~isOk
                                        if ~isRelTolUsed
                                            optMsg=sprintf(...
                                                ['absolute tolerance=%g,',...
                                                ' expected tolerance=%g'], ...
                                                actAbsTol, expTol);
                                        else
                                            optMsg=sprintf(...
                                                ['relative tolerance=%g,'...
                                                ' absolute tolerance=%g,',...
                                                ' expected tolerance=%g'], ...
                                                actRelTol, actAbsTol, expTol);
                                        end
                                        throwError('value',fieldName,optMsg);
                                    end
                                end
                            end
                        end
                    end
                end
            end
            function normVec = vecArrNorm(inpMat)
                import gras.gen.MatVector;
                %
                nDims = size(inpMat);
                if all(nDims(1:2) == 1)
                    nDims = 1;
                end
                nDims = length(nDims);
                switch nDims
                    case 1
                        normVec = squeeze(abs(inpMat))';
                    case 2
                        normVec = MatVector.evalMFunc(@norm, shiftdim(...
                            inpMat, -1))';
                    case 3
                        normVec = MatVector.evalMFunc(@norm, inpMat)';
                    otherwise
                        optMsg=sprintf(...
                            ['Arrays with dimensionality = %u are not', ...
                            ' supported'], nDims);
                        throwError('value', fieldName, optMsg);
                end
            end
            function throwError(tagName,fieldName,optMsg)
                import modgen.common.throwerror;
                if nargin<3
                    optMsg='';
                else
                    optMsg=[',',optMsg];
                end
                throwerror('wrongInput:touchCurveDependency',...
                    ['%s of field %s is expected to be ',...
                    'dependent only on (%s)%s'],tagName,fieldName,...
                    cell2sepstr([],dependencyFieldList,','),optMsg);
            end
        end
    end
end