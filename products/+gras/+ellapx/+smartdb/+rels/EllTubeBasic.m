classdef EllTubeBasic<gras.ellapx.smartdb.rels.EllTubeTouchCurveBasic
    %TestRelation Summary of this class goes here
    %   Detailed explanation goes here
    properties (Constant,Hidden)
        FCODE_Q_ARRAY
        FCODE_A_MAT
        FCODE_SCALE_FACTOR
        FCODE_M_ARRAY
    end
    methods
        function fieldsList = getNoCatOrCutFieldsList(~)
            import  gras.ellapx.smartdb.F;
            fieldsList=F().getNameList({'APPROX_SCHEMA_DESCR';'DIM';...
                'APPROX_SCHEMA_NAME';'APPROX_TYPE';'CALC_PRECISION';...
                'IND_S_TIME';'LS_GOOD_DIR_NORM';'LS_GOOD_DIR_VEC';'S_TIME';...
                'SCALE_FACTOR';'XS_TOUCH_OP_VEC';'XS_TOUCH_VEC'});
        end
    end
    methods (Access = protected)
        function fieldsList = getSFieldsList(~)
            import gras.ellapx.smartdb.F;
            fieldsList = F().getNameList({'LS_GOOD_DIR_VEC';'LS_GOOD_DIR_NORM';...
                'XS_TOUCH_VEC';'XS_TOUCH_OP_VEC'});
        end
        function fieldsList = getTFieldsList(~)
            import  gras.ellapx.smartdb.F;
            fieldsList = F().getNameList({'LT_GOOD_DIR_MAT';...
                'LT_GOOD_DIR_NORM_VEC';'X_TOUCH_CURVE_MAT';...
                'X_TOUCH_OP_CURVE_MAT'});
        end
        function fieldsList = getScalarFieldsList(~)
            import  gras.ellapx.smartdb.F;
            fieldsList = F().getNameList({'LS_GOOD_DIR_NORM'});
        end
    end
    methods(Access=protected, Abstract)
        checkIfObjectScalar(~);
    end
    methods (Static, Access=protected,Sealed)
        function [xTouchMat,xTouchOpMat]=calcTouchCurves(QArray,aMat,...
                ltGoodDirMat)
            import gras.ellapx.common.*;
            import gras.gen.SquareMatVector;
            Qsize=size(QArray);
            tmp=SquareMatVector.rMultiplyByVec(QArray,ltGoodDirMat);
            denominator=realsqrt(abs(sum(tmp.*ltGoodDirMat)));
            temp=tmp./denominator(ones(1,Qsize(2)),:);
            xTouchOpMat=aMat-temp;
            xTouchMat=aMat+temp;
        end
        %
        function STubeData=scaleTubeData(STubeData,scaleFactorVec)
            import gras.ellapx.smartdb.rels.EllTubeBasic;
            import gras.gen.SquareMatVector;
            scaleQFactorVec=scaleFactorVec.*scaleFactorVec;
            scaleQFactorList=num2cell(scaleQFactorVec);
            %
            STubeData.QArray=cellfun(@(x,y)x.*y,STubeData.QArray,...
                scaleQFactorList,'UniformOutput',false);
            STubeData.QArray=cellfun(@(x)0.5*(x+SquareMatVector.transpose(x)),STubeData.QArray,...
                'UniformOutput',false);
            STubeData.MArray=cellfun(@(x,y)x.*y,STubeData.MArray,...
                scaleQFactorList,'UniformOutput',false);
            %
            STubeData=EllTubeBasic.calcTouchCurveData(STubeData);
            STubeData.scaleFactor=STubeData.scaleFactor.*scaleFactorVec;
        end
        %
        function STubeData=calcTouchCurveData(STubeData)
            import gras.ellapx.smartdb.rels.EllTubeBasic;
            nLDirs=length(STubeData.QArray);
            STubeData.xsTouchVec=cell(nLDirs,1);
            STubeData.xsTouchOpVec=cell(nLDirs,1);
            %
            STubeData.xTouchCurveMat=cell(nLDirs,1);
            STubeData.xTouchOpCurveMat=cell(nLDirs,1);
            %
            for iLDir=1:nLDirs
                indSTime=STubeData.indSTime(iLDir);
                [STubeData.xTouchCurveMat{iLDir},...
                    STubeData.xTouchOpCurveMat{iLDir}]=...
                    EllTubeBasic.calcTouchCurves(...
                    STubeData.QArray{iLDir},STubeData.aMat{iLDir},...
                    STubeData.ltGoodDirMat{iLDir});
                %
                STubeData.xsTouchVec{iLDir}=...
                    STubeData.xTouchCurveMat{iLDir}(:,indSTime);
                STubeData.xsTouchOpVec{iLDir}=...
                    STubeData.xTouchOpCurveMat{iLDir}(:,indSTime);
            end
        end
        function STubeData=calcGoodCurveData(STubeData)
            import modgen.common.throwerror;
            nLDirs=length(STubeData.QArray);
            STubeData.indSTime=zeros(nLDirs,1);
            STubeData.lsGoodDirVec=cell(nLDirs,1);
            STubeData.ltGoodDirNormVec=cell(nLDirs,1);
            STubeData.lsGoodDirNorm=zeros(nLDirs,1);
            %
            for iLDir=1:nLDirs
                timeVec=STubeData.timeVec{iLDir};
                sTime=STubeData.sTime(iLDir);
                indSTime=find(sTime==timeVec,1,'first');
                if isempty(indSTime)
                    throwerror('wrongInput:sTimeOutOfBounds',...
                        'sTime is expected to be among elements of timeVec');
                end      
                ltGoodDirMat=STubeData.ltGoodDirMat{iLDir};
                lsGoodDirVec=ltGoodDirMat(:,indSTime);
                STubeData.indSTime(iLDir)=indSTime;
                STubeData.lsGoodDirVec{iLDir}=lsGoodDirVec;
                STubeData.lsGoodDirNorm(iLDir)=...
                    realsqrt(sum(lsGoodDirVec.*lsGoodDirVec));                
                STubeData.ltGoodDirNormVec{iLDir}=realsqrt(sum(...
                    ltGoodDirMat.*ltGoodDirMat,1));                
            end
        end        
        function STubeData=fromQArraysInternal(QArrayList,aMat,...
                MArrayList,timeVec,ltGoodDirArray,sTime,approxType,...
                approxSchemaName,approxSchemaDescr,calcPrecision,scaleFactorVec)
            %
            % $Author: Peter Gagarinov  <pgagarinov@gmail.com> $        $Date: 2011 $
            % $Copyright: Moscow State University,
            %            Faculty of Computational Mathematics and Computer Science,
            %            System Analysis Department 2011 $
            %
            import modgen.common.throwerror;
            import gras.ellapx.common.*;
            import gras.gen.SquareMatVector;
            import gras.ode.MatrixODESolver;
            import gras.ellapx.smartdb.rels.EllTubeBasic;
            import modgen.common.type.simple.checkgenext;
            %
            checkgenext(['numel(x1)==numel(x2)&&numel(x2)==numel(x3)',...
                '&&isrow(x1)&&isrow(x2)&&isrow(x3)&&isnumeric(x3)'],3,...
                QArrayList,MArrayList,scaleFactorVec);
            %
            nLDirs=length(QArrayList);
            STubeData=struct;
            %
            STubeData.scaleFactor=ones(nLDirs,1);
            if (numel(approxType) == 1)
                STubeData.approxType=repmat(approxType,nLDirs,1);
            else
                STubeData.approxType = approxType;
            end
            STubeData.QArray=QArrayList.';
            STubeData.aMat=repmat({aMat},nLDirs,1);
            %
            STubeData.MArray=MArrayList.';
            %
            STubeData.dim=repmat(size(aMat,1),nLDirs,1);
            %
            STubeData.sTime=repmat(sTime,nLDirs,1);
            %
            STubeData.timeVec=repmat({timeVec},nLDirs,1);
            %
            STubeData.approxSchemaName=repmat({approxSchemaName},...
                nLDirs,1);
            STubeData.approxSchemaDescr=repmat({approxSchemaDescr},...
                nLDirs,1);
            %
            STubeData.ltGoodDirMat=cell(nLDirs,1);
            %
            STubeData.ltGoodDirNormVec=cell(nLDirs,1);
            STubeData.calcPrecision=repmat(calcPrecision,nLDirs,1);
            %
            for iLDir=1:1:nLDirs
                STubeData.ltGoodDirMat{iLDir}=...
                    squeeze(ltGoodDirArray(:,iLDir,:));
            end
            STubeData=EllTubeBasic.calcGoodCurveData(STubeData);
            STubeData=EllTubeBasic.scaleTubeData(STubeData,scaleFactorVec.');
            STubeData=EllTubeBasic.calcTouchCurveData(STubeData);
        end
    end
    methods (Access=protected)
        function dependencyFieldList=getTouchCurveDependencyFieldList(~)
            dependencyFieldList={'sTime','lsGoodDirVec','MArray'};
        end
        function checkTouchCurveVsQNormArray(~,tubeRel,curveRel,...
                fTolFunc,checkName,fFilterFunc)
            nTubes=tubeRel.getNTuples();
            nCurves=curveRel.getNTuples();
            QArrayList=tubeRel.QArray;
            aMatList=tubeRel.aMat;
            xTouchCurveMatList=curveRel.xTouchCurveMat;
            xTouchOpCurveMatList=curveRel.xTouchOpCurveMat;
            curveCalcPrecVec=curveRel.calcPrecision;
            tubeCalcPrecVec=tubeRel.calcPrecision;
            tubeScaleFactorVec=tubeRel.scaleFactor;
            curveScaleFactorVec=curveRel.scaleFactor;
            %
            for iCurve=1:nCurves
                curveScaleFactor=curveScaleFactorVec(iCurve);
                for iTube=1:nTubes
                    tubeScaleFactor=tubeScaleFactorVec(iTube);
                    if ~fFilterFunc(iTube,iCurve)
                        continue;
                    end
                    scaleFactorRatio=curveScaleFactor/tubeScaleFactor;
                    QArray=QArrayList{iTube}*scaleFactorRatio*...
                        scaleFactorRatio;
                    calcPrecision=(curveCalcPrecVec(iCurve)+...
                        tubeCalcPrecVec(iTube)*scaleFactorRatio);
                    checkNorm(QArray,aMatList{iTube},...
                        xTouchCurveMatList{iCurve},calcPrecision,...
                        'xTouchCurveMat');
                    checkNorm(QArray,aMatList{iTube},...
                        xTouchOpCurveMatList{iCurve},calcPrecision,...
                        'xTouchOpCurveMat');
                end
            end
            function checkNorm(QArray,aMat,xTouchCurveMat,...
                    calcPrecision,fieldName)
                import modgen.common.throwerror;
                normVec=gras.gen.SquareMatVector.lrDivideVec(...
                    QArray,xTouchCurveMat-aMat);
                actualPrecision=max(fTolFunc(normVec));
                isOk=actualPrecision<=calcPrecision;
                if ~isOk
                    throwerror('wrongInput:touchLineValueFunc',...
                        ['check [%s] has failed for %s, ',...
                        'expected precision=%d, actual precision=%d'],...
                        checkName,fieldName,calcPrecision,actualPrecision);
                end
            end
        end
        function checkIntWithinExt(~,intRel,extRel)
            [~,~,~,indIntForwardVec,indIntBackwardVec]=...
                intRel.getUniqueData('fieldNameList',{'aMat'});
            [~,~,~,indExtForwardVec,indExtBackwardVec]=...
                extRel.getUniqueData('fieldNameList',{'aMat'});
            QIntArrayList=intRel.applyTupleGetFunc(@(x,y)x./(y.*y),...
                {'QArray','scaleFactor'},'UniformOutput',false);
            intCalcPrecVec=intRel.calcPrecision;
            %
            QExtArrayList=extRel.applyTupleGetFunc(@(x,y)x./(y.*y),...
                {'QArray','scaleFactor'},'UniformOutput',false);
            extCalcPrecVec=extRel.calcPrecision;
            %
            nIntGroups=length(indIntForwardVec);
            nExtGroups=length(indExtForwardVec);
            for iIntGroup=1:nIntGroups
                indIntVec=find(indIntBackwardVec==iIntGroup);
                for iExtGroup=1:nExtGroups
                    indExtVec=find(indExtBackwardVec==iExtGroup);
                    [indIntMat,indExtMat]=ndgrid(indIntVec,indExtVec);
                    QIntArrayCmpList=QIntArrayList(indIntMat(:));
                    QExtArrayCmpList=QExtArrayList(indExtMat(:));
                    %
                    intCalcPrecCmpList=num2cell(intCalcPrecVec(indIntMat(:)));
                    extCalcPrecCmpList=num2cell(extCalcPrecVec(indExtMat(:)));
                    %
                    cellfun(...
                        @(q1,q2,p1,p2)checkIntWithinExt(q1,q2,p1+p2),...
                        QExtArrayCmpList,QIntArrayCmpList,...
                        extCalcPrecCmpList,intCalcPrecCmpList);
                end
            end
            function minEig=checkIntWithinExt(QExtArray,QIntArray,calcPrec)
                import gras.gen.SquareMatVector;
                import modgen.common.throwerror;
                QExtSqrtArray=SquareMatVector.sqrtmpos(QExtArray);
                QIntSqrtArray=SquareMatVector.sqrtmpos(QIntArray);
                minEig=min(SquareMatVector.evalMFunc(@(x)min(eig(x)),...
                    QExtSqrtArray-QIntSqrtArray));
                if minEig+calcPrec<0
                    throwerror('wrongInput:internalWithinExternal',...
                        sprintf(['internal approximation should be ',...
                        'within external appproximation with ',...
                        'tolerance %f, actual tolerance is %f'],...
                        calcPrec,abs(minEig)));
                end
                
            end
        end
        function checkTouchCurves(self,fullRel)
            import gras.ellapx.enums.EApproxType;
            %
            self.checkTouchCurveVsQNormArray(fullRel,fullRel,...
                @(x)abs(x-1),...
                'any touch line should be on the boundary of its tube',...
                @(x,y)x==y);
            %
            intRel=fullRel.getTuplesFilteredBy('approxType',EApproxType.Internal);
            self.checkTouchCurveVsQNormArray(intRel,fullRel,...
                @(x)max(1-x),...
                'any touch line is always outside any internal approx',...
                @(x,y)true);
            %
            extRel=fullRel.getTuplesFilteredBy('approxType',EApproxType.External);
            self.checkTouchCurveVsQNormArray(extRel,fullRel,...
                @(x)max(x-1),...
                'any touch line is always within any external approx',...
                @(x,y)true);
            %
            self.checkIntWithinExt(intRel,extRel);
            %
        end
        function checkDataConsistency(self)
            import modgen.common.throwerror;
            import modgen.common.num2cell;
            %
            if self.getNTuples()>0
                checkFieldList={'QArray','aMat','scaleFactor',...
                    'MArray','dim','sTime','approxSchemaName',...
                    'approxSchemaDescr','approxType','timeVec',...
                    'calcPrecision','indSTime','ltGoodDirMat',...
                    'lsGoodDirVec','ltGoodDirNormVec',...
                    'lsGoodDirNorm','xTouchCurveMat',...
                    'xTouchOpCurveMat','xsTouchVec','xsTouchOpVec'};
                %
                fCheckTuple=@(QArray,aMat,scaleFactor,MArray,...
                    dim,sTime,approxSchemaName,approxSchemaDescr,...
                    approxType,timeVec,calcPrecision,indSTime,...
                    ltGoodDirMat,lsGoodDirVec,ltGoodDirNormVec,...
                    lsGoodDirNorm,xTouchCurveMat,xTouchOpCurveMat,...
                    xsTouchVec,xsTouchOpVec)...
                    checkTuple(QArray,aMat,scaleFactor,MArray,...
                    dim,sTime,approxSchemaName,approxSchemaDescr,...
                    approxType,timeVec,calcPrecision,indSTime,...
                    ltGoodDirMat,lsGoodDirVec,ltGoodDirNormVec,...
                    lsGoodDirNorm,xTouchCurveMat,xTouchOpCurveMat,...
                    xsTouchVec,xsTouchOpVec);
                %
                [isOkList,errTagList,reasonList]=...
                    self.applyTupleGetFunc(fCheckTuple,checkFieldList,...
                    'UniformOutput',false);
                %
                isOkVec=vertcat(isOkList{:});
                if ~all(isOkVec)
                    indFirst=find(~isOkVec,1,'first');
                    errTag=errTagList{indFirst};
                    reasonStr=reasonList{indFirst};
                    throwerror(['wrongInput:',errTag],...
                        ['Tuples with indices %s have inconsistent ',...
                        'values, reason: ',reasonStr],...
                        mat2str(find(~isOkVec)));
                end
                checkDataConsistency@...
                    gras.ellapx.smartdb.rels.EllTubeTouchCurveBasic(self);
                %% Check that touch lines lie within the tubes
                probDepFieldList=self.getProblemDependencyFieldList();
                [~,~,~,indForwardVec,indBackwardVec]=...
                    self.getUniqueData('fieldNameList',probDepFieldList);
                nGroups=length(indForwardVec);
                for iGroup=1:nGroups
                    isGroupVec=indBackwardVec==iGroup;
                    [SData,SIsNull,SIsValueNull]=self.getData(isGroupVec);
                    self.checkTouchCurves(...
                        smartdb.relations.DynamicRelation(...
                        SData,SIsNull,SIsValueNull));
                end
            end
            function [isOk,errTagStr,reasonStr]=checkTuple(QArray,aMat,...
                    scaleFactor,MArray,dim,sTime,approxSchemaName,...
                    approxSchemaDescr,approxType,timeVec,calcPrecision,...
                    indSTime,ltGoodDirMat,lsGoodDirVec,ltGoodDirNormVec,...
                    lsGoodDirNorm,xTouchCurveMat,xTouchOpCurveMat,...
                    xsTouchVec,xsTouchOpVec)
                import gras.gen.SquareMatVector;
                errTagStr='';
                reasonStr='';
                isOk=false;
                isNotPosDefVec=SquareMatVector.evalMFunc(...
                    @(x)~gras.la.ismatposdef(x,calcPrecision),QArray);
                if any(isNotPosDefVec)
                    errTagStr='QArrayNotPos';
                    reasonStr='QArray is not positively defined';
                    return;
                end
                %
                [~,indSortVec]=unique(timeVec); %unique sorts input values
                if length(indSortVec)~=length(timeVec);
                    errTagStr='timeVecNotUnq';
                    reasonStr='timeVec contains non-unique values';
                    return;
                elseif any(diff(indSortVec)<0)
                    errTagStr='timeVecNotMon';
                    reasonStr='timeVec is not monotone';
                    return;
                end
                %
                isNotPosDefVec=SquareMatVector.evalMFunc(...
                    @(x)~gras.la.ismatposdef(x,calcPrecision,true),MArray);
                if any(isNotPosDefVec)
                    errTagStr='MArrayNeg';
                    reasonStr='MArray is negatively defined';
                    return;
                end
                nPoints=size(timeVec,2);
                nDims=size(QArray,1);
                isOk=size(QArray,3)==nPoints&&...
                    size(MArray,3)==nPoints&&...
                    size(aMat,2)==nPoints&&...
                    size(ltGoodDirMat,2)==nPoints&&...
                    size(xTouchCurveMat,2)==nPoints&&...
                    size(xTouchOpCurveMat,2)==nPoints&&...
                    size(timeVec,1)==1&&...
                    ismatrix(timeVec)&&size(MArray,1)==nDims&&...
                    size(MArray,2)==nDims&&size(QArray,2)==nDims&&...
                    size(ltGoodDirMat,1)==nDims&&...
                    size(xTouchCurveMat,1)==nDims&&...
                    size(xsTouchVec,1)==nDims&&...
                    size(xsTouchOpVec,1)==nDims&&...
                    size(lsGoodDirVec,1)==nDims&&...
                    size(ltGoodDirNormVec,2)==nPoints&&...
                    size(ltGoodDirNormVec,1)==1&&...
                    numel(indSTime)==1&&...
                    numel(scaleFactor)==1&&numel(lsGoodDirNorm)==1&&...
                    numel(dim)==1&&numel(sTime)==1&&...
                    numel(calcPrecision)==1&&...
                    size(approxSchemaName,1)==1&&...
                    size(approxSchemaName,2)==numel(approxSchemaName)&&...
                    size(approxSchemaDescr,1)==1&&...
                    size(approxSchemaDescr,2)==numel(approxSchemaDescr)&&...
                    numel(approxType)==1&&size(aMat,1)==nDims&&...
                    dim==nDims;
                if ~isOk
                    reasonStr='Fields have inconsistent sizes';
                    errTagStr='badSize';
                    return;
                end
                isOk=true;
            end
        end
        function SData = getInterpDataInternal(self, newTimeVec)
            import gras.ellapx.smartdb.F;
            import gras.ellapx.smartdb.rels.EllTubeBasic;
            SData=self.getData();
            [SData.QArray, SData.aMat, SData.MArray,...
                    SData.ltGoodDirMat,SData.timeVec,sTimeList] =...
                    cellfun(@fInterpTuple,SData.QArray,...
                    SData.aMat, SData.MArray,...
                    SData.ltGoodDirMat,SData.timeVec,...
                    num2cell(SData.sTime),'UniformOutput',false);
            SData.sTime=vertcat(sTimeList{:});    
            SData=EllTubeBasic.calcGoodCurveData(SData);
            SData=EllTubeBasic.calcTouchCurveData(SData);
            %
            function [QArray, aMat, MArray,ltGoodDirMat,timeVec,sTime] =...
                    fInterpTuple(QArray, aMat, MArray,ltGoodDirMat,...
                    timeVec,sTime)
                QArray = simpleInterp(QArray,'symm_column_triu');
                MArray = simpleInterp(MArray,'symm_column_triu');
                ltGoodDirMat = simpleInterp(ltGoodDirMat,'column');
                aMat = simpleInterp(aMat,'column');
                timeVec=newTimeVec;
                distVec=abs(sTime-newTimeVec);
                [~,indMin]=min(distVec);
                sTime=newTimeVec(indMin);
                function interpArray=simpleInterp(inpArray,interpType)
                    import gras.interp.MatrixInterpolantFactory;                    
                    splineObj=MatrixInterpolantFactory.createInstance(...
                        interpType,inpArray,timeVec);
                    interpArray=splineObj.evaluate(newTimeVec);
                end
            end
        end
    end
    methods (Access=protected)
        function [ellTubeProjRel,indProj2OrigVec]=projectInternal(self,projType,...
                projMatList,fGetProjMat)
            import gras.ellapx.uncertcalc.common.*;
            import modgen.common.throwerror;
            import gras.ellapx.common.*;
            import import gras.ellapx.enums.EProjType;
            import gras.gen.SquareMatVector;
            import gras.ellapx.smartdb.rels.EllTubeBasic;
            %
            projDependencyFieldNameList=...
                self.getProjectionDependencyFieldList();
            %
            nProj=length(projMatList);
            [SUData,~,~,indForwardVec,indBackwardVec]=...
                self.getUniqueData('fieldNameList',...
                projDependencyFieldNameList);
            %
            nGroups=length(indForwardVec);
            STubeData=self.getData();
            %
            tubeProjDataCMat=cell(nGroups,nProj);
            %
            indProj2OrigCVec=cell(nGroups);
            %
            for iGroup=1:nGroups
                timeVec=SUData.timeVec{iGroup};
                sTime=SUData.sTime(iGroup);
                indSTime=SUData.indSTime(iGroup);
                dim=SUData.dim;
                indLDirs=find(indBackwardVec==iGroup);
                indProj2OrigCVec{iGroup}=indLDirs;
                nLDirs=length(indLDirs);
                %
                for iProj=nProj:-1:1
                    projMat=projMatList{iProj};
                    %% Create projection matrix vector
                    [projOrthMatArray,projOrthMatTransArray]=...
                        fGetProjMat(projMat,timeVec,sTime,dim,indSTime);
                    %%
                    %
                    tubeProjDataCMat{iGroup,iProj}.dim=...
                        repmat(size(projMat,1),nLDirs,1);
                    tubeProjDataCMat{iGroup,iProj}.projSTimeMat=...
                        repmat({projMat},nLDirs,1);
                    tubeProjDataCMat{iGroup,iProj}.projArray=...
                        repmat({projOrthMatArray},nLDirs,1);
                    tubeProjDataCMat{iGroup,iProj}.projType=...
                        repmat(projType,nLDirs,1);
                    %
                    tubeProjDataCMat{iGroup,iProj}.QArray=cell(nLDirs,1);
                    tubeProjDataCMat{iGroup,iProj}.aMat=cell(nLDirs,1);
                    %
                    tubeProjDataCMat{iGroup,iProj}.MArray=cell(nLDirs,1);
                    %
                    tubeProjDataCMat{iGroup,iProj}.xTouchCurveMat=cell(nLDirs,1);
                    tubeProjDataCMat{iGroup,iProj}.xTouchOpCurveMat=cell(nLDirs,1);
                    %
                    tubeProjDataCMat{iGroup,iProj}.sTime=repmat(sTime,nLDirs,1);
                    tubeProjDataCMat{iGroup,iProj}.indSTime=repmat(...
                        indSTime,nLDirs,1);
                    %
                    tubeProjDataCMat{iGroup,iProj}.timeVec=repmat({timeVec},nLDirs,1);
                    %
                    tubeProjDataCMat{iGroup,iProj}.lsGoodDirVec=cell(nLDirs,1);
                    tubeProjDataCMat{iGroup,iProj}.ltGoodDirMat=cell(nLDirs,1);
                    tubeProjDataCMat{iGroup,iProj}.lsGoodDirNorm=zeros(nLDirs,1);
                    tubeProjDataCMat{iGroup,iProj}.ltGoodDirNormVec=cell(nLDirs,1);
                    tubeProjDataCMat{iGroup,iProj}.lsGoodDirNormOrig=zeros(nLDirs,1);
                    tubeProjDataCMat{iGroup,iProj}.ltGoodDirNormOrigVec=cell(nLDirs,1);
                    tubeProjDataCMat{iGroup,iProj}.lsGoodDirOrigVec=cell(nLDirs,1);
                    tubeProjDataCMat{iGroup,iProj}.ltGoodDirOrigMat=cell(nLDirs,1);
                    %
                    tubeProjDataCMat{iGroup,iProj}.xsTouchVec=cell(nLDirs,1);
                    tubeProjDataCMat{iGroup,iProj}.xsTouchOpVec=cell(nLDirs,1);
                    
                    %
                    tubeProjDataCMat{iGroup,iProj}.approxSchemaName=...
                        STubeData.approxSchemaName(indLDirs);
                    tubeProjDataCMat{iGroup,iProj}.approxSchemaDescr=...
                        STubeData.approxSchemaDescr(indLDirs);
                    tubeProjDataCMat{iGroup,iProj}.approxType=...
                        STubeData.approxType(indLDirs);
                    %
                    tubeProjDataCMat{iGroup,iProj}.calcPrecision=...
                        STubeData.calcPrecision(indLDirs);
                    tubeProjDataCMat{iGroup,iProj}.scaleFactor=...
                        STubeData.scaleFactor(indLDirs);
                    %
                    projOrthSTimeMat=projOrthMatArray(:,:,indSTime);
                    %
                    for iLDir=1:nLDirs
                        iOLDir=indLDirs(iLDir);
                        tubeProjDataCMat{iGroup,iProj}.lsGoodDirOrigVec{iOLDir}=...
                            STubeData.lsGoodDirVec{iOLDir};
                        tubeProjDataCMat{iGroup,iProj}.ltGoodDirOrigMat{iOLDir}=...
                            STubeData.ltGoodDirMat{iOLDir};
                        tubeProjDataCMat{iGroup,iProj}.ltGoodDirMat{iLDir}=...
                            SquareMatVector.rMultiplyByVec(projOrthMatArray,...
                            STubeData.ltGoodDirMat{iOLDir});
                        %project configuration matrices
                        tubeProjDataCMat{iGroup,iProj}.QArray{iLDir}=...
                            SquareMatVector.rMultiply(projOrthMatArray,...
                            STubeData.QArray{iOLDir},projOrthMatTransArray);
                        %Matrices must remain symmetric
                        tubeProjDataCMat{iGroup,iProj}.QArray{iLDir}=...
                            0.5*(tubeProjDataCMat{iGroup,iProj}.QArray{iLDir}+...
                            SquareMatVector.transpose(...
                            tubeProjDataCMat{iGroup,iProj}.QArray{iLDir}));
                        %project centers
                        tubeProjDataCMat{iGroup,iProj}.aMat{iLDir}=...
                            SquareMatVector.rMultiplyByVec(projOrthMatArray,...
                            STubeData.aMat{iOLDir});
                        %project regularization matrix
                        tubeProjDataCMat{iGroup,iProj}.MArray{iLDir}=...
                            SquareMatVector.rMultiply(projOrthMatArray,...
                            STubeData.MArray{iOLDir},projOrthMatTransArray);
                        %Matrices must remain symmetric
                        tubeProjDataCMat{iGroup,iProj}.MArray{iLDir}=...
                            0.5*(tubeProjDataCMat{iGroup,iProj}.MArray{iLDir}+...
                            SquareMatVector.transpose(...
                            tubeProjDataCMat{iGroup,iProj}.MArray{iLDir}));
                        %
                        %the following statement only valid for orthogonal projections
                        tubeProjDataCMat{iGroup,iProj}.ltGoodDirMat{iLDir}=...
                            SquareMatVector.rMultiplyByVec(projOrthMatArray,...
                            STubeData.ltGoodDirMat{iOLDir});
                        %the following statement only valid for orthogonal projections
                        tubeProjDataCMat{iGroup,iProj}.lsGoodDirVec{iLDir}=projOrthSTimeMat*...
                            STubeData.lsGoodDirVec{iOLDir};
                        %calculate norms
                        lsGoodDirVec = tubeProjDataCMat{iGroup,iProj}.lsGoodDirVec{iLDir};
                        tubeProjDataCMat{iGroup,iProj}.lsGoodDirNorm(iLDir)=...
                            realsqrt(sum(lsGoodDirVec.*lsGoodDirVec));
                        %
                        tubeProjDataCMat{iGroup,iProj}.ltGoodDirNormVec{iLDir}=...
                            realsqrt(sum(...
                            tubeProjDataCMat{iGroup,iProj}.ltGoodDirMat{iLDir}.*...
                            tubeProjDataCMat{iGroup,iProj}.ltGoodDirMat{iLDir},1));
                        %record original norm values
                        tubeProjDataCMat{iGroup,iProj}.lsGoodDirNormOrig(iLDir)=...
                            STubeData.lsGoodDirNorm(iOLDir);
                        tubeProjDataCMat{iGroup,iProj}.ltGoodDirNormOrigVec{iLDir}=...
                            STubeData.ltGoodDirNormVec{iOLDir};
                        %
                        %project touch lines
                        tubeProjDataCMat{iGroup,iProj}.xTouchCurveMat{iLDir}=...
                            SquareMatVector.rMultiplyByVec(...
                            projOrthMatArray,STubeData.xTouchCurveMat{iOLDir});
                        %
                        tubeProjDataCMat{iGroup,iProj}.xTouchOpCurveMat{iLDir}=...
                            SquareMatVector.rMultiplyByVec(...
                            projOrthMatArray,STubeData.xTouchOpCurveMat{iOLDir});
                        %project touch points at time as
                        tubeProjDataCMat{iGroup,iProj}.xsTouchVec{iLDir}=projOrthSTimeMat*...
                            STubeData.xsTouchVec{iOLDir};
                        %
                        tubeProjDataCMat{iGroup,iProj}.xsTouchOpVec{iLDir}=projOrthSTimeMat*...
                            STubeData.xsTouchOpVec{iOLDir};
                    end
                end
            end
            ellTubeProjRel=...
                smartdb.relations.DynamicRelation.fromStructList(...
                tubeProjDataCMat);
            %
            indProj2OrigCMat=repmat(indProj2OrigCVec,1,nProj);
            indProj2OrigVec=vertcat(indProj2OrigCMat{:});
        end
    end
    methods
        function [apprEllMat timeVec] = getEllArray(self, approxType)
            % GETELLARRAY - returns array of matrix's ellipsoid according to
            %               approxType
            %
            % Input:
            %  regular:
            %     self.
            %     approxType:char[1,] - type of approximation(internal/external)
            %
            % Output:
            %   apprEllMat:double[nDim1,..., nDimN] - array of array of ellipsoid's
            %            matrices
            import gras.ellapx.enums.EApproxType;
            import gras.ellapx.smartdb.F;
            APPROX_TYPE = F.APPROX_TYPE;
            SData = self.getTuplesFilteredBy(APPROX_TYPE, approxType);
            nTuples = SData.getNTuples();
            if nTuples > 0
                apprEllMat = ellipsoid(...
                    cat(3,SData.aMat{1:nTuples}),...
                    cat(4,SData.QArray{1:nTuples}))';
            else
                apprEllMat = [];
            end
            if nargout > 1
                if (~isempty(SData.timeVec))
                    timeVec = SData.timeVec{1};
                else
                    timeVec = [];
                end
            end
        end
        %
        % INTERP - interpolates ellipsoidal tube on a new time vector
        %
        % Input:
        %   regular:
        %       self.
        %
        %       timeVec: double[nPoints] - sorted time vector to interpolate on.
        %                Must begin with self.timeVec[1] and end with
        %                self.timeVec[end]
        %
        % Output:
        %   obj: gras.ellapx.smartdb.rels.EllTubeBasic[1, 1] - interpolated
        %        ellipsoidal tube
        %
        % $Author: Daniil Stepenskiy <reinkarn@gmail.com> $
        % $Date: May-2013 $
        % $Copyright: Moscow State University,
        %             Faculty of Computational
        %             Mathematics and Computer Science,
        %             System Analysis Department 2013 $
        function interpEllTube = interp(self, timeVec)
            import gras.interp.MatrixInterpolantFactory;
            import gras.ellapx.smartdb.rels.EllTube;
            import modgen.common.throwerror;
            %
            self.checkIfObjectScalar();
            if (isempty(timeVec))
                throwerror('wrongInput',...
                    'time vector should not be empty');
            end
            if (~ismatrix(timeVec) || size(timeVec, 1)~=1)
                throwerror('wrongInput',...
                    'timeVec must be an array');
            end
            selfTimeVec = self.timeVec{1};
            if (timeVec(end) > selfTimeVec(end) ||...
                    timeVec(1) < selfTimeVec(1))
                throwerror('wrongInput',...
                    'no extrapolation allowed');
            end
            %
            if isempty(self)
                interpEllTube = self;
            else
                SData = self.getInterpDataInternal(timeVec);
                interpEllTube = self.createInstance(SData);
            end
        end
        %
        function thinnedEllTubeRel =...
                thinOutTuples(self, indVec)
            import gras.ellapx.smartdb.F;
            import modgen.common.throwerror;
            SData = self.getData();
            SThinFunResult = SData;
            timeVec = SData.timeVec{1};
            nPoints = numel(timeVec);
            if isa(indVec, 'double')
                if min(indVec) < 1 || max(indVec) > nPoints
                    throwerror('wrongInput','Indexes are out of range.');
                end
                isNeededIndVec = false(size(timeVec));
                isNeededIndVec(indVec) = true;
            elseif islogical(indVec)
                if numel(indVec) ~= nPoints
                    throwerror('wrongInput','Indexes are out of range.');
                end
                isNeededIndVec = indVec;
            else
                throwerror('wrongInput',...
                    'indVec should be double or logical');
            end
            SThinFunResult.timeVec=cellfun(...
                @(field)field(isNeededIndVec), SData.timeVec,...
                'UniformOutput', false);
            %
            if (isNeededIndVec(SData.indSTime))
                SThinFunResult.sTime(:) = SData.sTime(1);
                SThinFunResult.indSTime(:) = ...
                    find(find(isNeededIndVec)==SData.indSTime(1));
            else
                SThinFunResult.sTime(:) =...
                    timeVec(find(isNeededIndVec, 1));
                SThinFunResult.indSTime(:) = 1;
            end
            fieldsNotToCatVec =...
                self.getNoCatOrCutFieldsList();
            fieldsToCutVec =...
                setdiff(fieldnames(SData), fieldsNotToCatVec);
            cellfun(@(field) cutStructField(field), fieldsToCutVec);
            cellfun(@cutStructSTimeField, self.getSFieldsList(),...
                self.getTFieldsList());
            cellfun(@(field)fMakeCell(field),self.getScalarFieldsList());
            %
            thinnedEllTubeRel = self.createInstance(SThinFunResult);
            %
            function fMakeCell(fieldName)
                SThinFunResult.(fieldName) = ...
                    cell2mat(SThinFunResult.(fieldName));
            end
            %
            function cutStructSTimeField(fieldNameTo, fieldNameFrom)
                SThinFunResult.(fieldNameTo) =...
                    cellfun(@(field)field(:,SThinFunResult.indSTime(1)),...
                    SThinFunResult.(fieldNameFrom),...
                    'UniformOutput', false);
            end
            %
            function cutResObj = getCutObj(whatToCutObj, isCutTimeVec)
                dim = ndims(whatToCutObj);
                if dim == 1
                    cutResObj = whatToCutObj(isCutTimeVec);
                elseif dim == 2
                    cutResObj = whatToCutObj(:, isCutTimeVec);
                elseif dim == 3
                    cutResObj = whatToCutObj(:, :, isCutTimeVec);
                end
            end
            %
            function cutStructField(fieldName)
                SThinFunResult.(fieldName) = cellfun(@(StructFieldVal)...
                    getCutObj(StructFieldVal, isNeededIndVec),...
                    SData.(fieldName), 'UniformOutput', false);
            end
        end
    end
    methods (Access=protected)
        function [isPos, reportStr] = isEqualAdjustedInternal(self, ellTubeObj, varargin)
            % ISEQUAL - compares current relation object with other relation object and 
            %           returns true if they are equal, otherwise it returns false
            % 
            %
            % Usage: isEq=isEqual(self,otherObj)
            %
            % Input:
            %   regular:
            %     self: ARelation [1,1] - current relation object
            %     otherObj: ARelation [1,1] - other relation object
            %
            %   properties:
            %     checkFieldOrder/isFieldOrderCheck: logical [1,1] - if true, then fields 
            %         in compared relations must be in the same order, otherwise the 
            %         order is not  important (false by default)        
            %     checkTupleOrder: logical[1,1] -  if true, then the tuples in the 
            %         compared relations are expected to be in the same order,
            %         otherwise the order is not important (false by default)
            %         
            %     maxTolerance: double [1,1] - maximum allowed tolerance            
            %
            %     compareMetaDataBackwardRef: logical[1,1] if true, the CubeStruct's
            %         referenced from the meta data objects are also compared            
            %
            %     notComparedFieldList: cell[1,nFields] of char[1,] - list
            %        of fields that are not compared
            %     
            %     areTimeBoundsCompared: logical[1,1] - if false,
            %       ellipsoidal tubes are compared on intersection of
            %       definition domains
            %
            % Output:
            %   isEq: logical[1,1] - result of comparison
            %   reportStr: char[1,] - report of comparsion
            %
            %
            % $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2013-06-13 $ 
            % $Copyright: Moscow State University,
            %            Faculty of Computational Mathematics and Computer Science,
            %            System Analysis Department 2012 $
            %
            import gras.ellapx.smartdb.F;
            import gras.ellapx.enums.EApproxType;
            import elltool.logging.Log4jConfigurator;
            import modgen.common.throwerror;
            %
            self.checkIfObjectScalar();
            ellTubeObj.checkIfObjectScalar();
            if (~isempty(setdiff(self.getFieldNameList(),...
                    ellTubeObj.getFieldNameList())))
                throwerror('wrongInput',...
                    'tubes must be of the same type');
            end
            persistent logger;
            reportStr = '';
            [reg, ~,...
                maxCompareTol,notComparedFieldList,areTimeBoundsCompared,...
                isTupleOrderChecked,isMaxCompareTolSpec] = ...
                modgen.common.parseparext(...
                varargin,{...
                'maxTolerance','notComparedFieldList',...
                'areTimeBoundsCompared','checkTupleOrder';...
                [],{},false,true;...
                'isscalar(x)&&isnumeric(x)&&x>0','iscellofstring(x)',...
                'isscalar(x)&&islogical(x)','isscalar(x)&&islogical(x)'});
            if ~isMaxCompareTolSpec
                maxCompareTol=max(self.calcPrecision)+...
                    max(ellTubeObj.calcPrecision);
            end
            %
            SSORT_KEYS=F().getNameList({...
                'S_TIME','LS_GOOD_DIR_VEC','APPROX_TYPE'});
            MUST_FIELD_CODES_NOT_TO_COMPARE={'IND_S_TIME','TIME_VEC'};
            notComparedFieldList=[notComparedFieldList,...
                F().getNameList(MUST_FIELD_CODES_NOT_TO_COMPARE)];
            %
            %TODO: the following line is temporary solution until we
            %replace calcPrecision with absTol and relTol
            absTol = maxCompareTol;
            %
            ellTube = self;
            compEllTube = ellTubeObj;
            ellTube.sortBy(SSORT_KEYS);
            compEllTube.sortBy(SSORT_KEYS);
            %
            isFirstEmpty=ellTube.getNTuples()==0;
            isSecondEmpty=compEllTube.getNTuples()==0;
            if isFirstEmpty&&isSecondEmpty
                isPos = true;
                reportStr = 'Comparing empty elltubes';
            elseif isFirstEmpty||isSecondEmpty
                isPos = false;
                reportStr = 'Comparing empty elltube with nonempty';
            else
                isPos=true;
                pointsNum = numel(ellTube.timeVec{1});
                newPointsNum = numel(compEllTube.timeVec{1});
                firstTimeVec = ellTube.timeVec{1};
                secondTimeVec = compEllTube.timeVec{1};
                %
                if isempty(logger)
                    logger=Log4jConfigurator.getLogger();
                end
                %
                if logger.isDebugEnabled
                    if pointsNum ~= newPointsNum
                        logger.debug('Inequal time knots count');
                    else
                        logger.debug('Equal time knots count');
                    end
                end
                %
                % Checking time bounds equality
                %
                areEndTimesDifferent = ...
                    abs(firstTimeVec(end)-secondTimeVec(end)) > absTol;
                areBeginTimesDifferent = ...
                    abs(firstTimeVec(1)-secondTimeVec(1)) > absTol;
                if areTimeBoundsCompared
                    if areBeginTimesDifferent
                        isPos = false;
                        reportStr=[reportStr, ...
                            sprintf('Ending times differ by %f. ',...
                            abs(firstTimeVec(end)-secondTimeVec(end)))];
                    elseif areEndTimesDifferent
                        isPos = false;
                        reportStr=[reportStr, ...
                            sprintf('Beginning times differ by %f. ',...
                            abs(firstTimeVec(1)-secondTimeVec(1)))];
                    end
                end
                if isPos
                    % Checking enclosion of time vectors
                    areFirstTimesInsideSecond = ...
                        (firstTimeVec(end)<=secondTimeVec(end)) &&...
                        (firstTimeVec(1)>=secondTimeVec(1));
                    %
                    areSecondTimesInsideFirst = ...
                        (secondTimeVec(end)<=firstTimeVec(end)) &&...
                        (secondTimeVec(1)>=firstTimeVec(1));
                    %
                    if (length(firstTimeVec) < length(secondTimeVec) &&...
                            areFirstTimesInsideSecond)
                        [isTimeVecsEnclosed, secondIndexVec] = ...
                            fIsGridSubsetOfGrid(secondTimeVec, firstTimeVec);
                    else
                        [isTimeVecsEnclosed, firstIndexVec] = ...
                            fIsGridSubsetOfGrid(firstTimeVec, secondTimeVec);
                    end
                    %
                    fieldsToCompList=setdiff(ellTube.getFieldNameList,...
                        notComparedFieldList);
                    %
                    if isTimeVecsEnclosed
                        reportStr = [reportStr,...
                            'Enclosed time vectors. Common times checked. '];
                        if numel(firstTimeVec) < numel(secondTimeVec)
                            compEllTube = ...
                                compEllTube.thinOutTuples(secondIndexVec);
                        elseif (length(firstTimeVec) > length(secondTimeVec))
                            ellTube = ellTube.thinOutTuples(firstIndexVec);
                        end
                        [isPos, eqReportStr] = compEllTube.getFieldProjection(...
                            fieldsToCompList).isEqual(...
                            ellTube.getFieldProjection(fieldsToCompList),...
                            'maxTolerance', maxCompareTol,...
                            'checkTupleOrder','true',reg{:});
                        reportStr = [reportStr, eqReportStr];
                    else
                        %
                        % Time vectors are not enclosed,
                        %
                        % So interpolating from common time knots
                        %
                        reportStr = [reportStr, 'Interpolated from common ',...
                            'time points. '];
                        unionTimeVec = union(firstTimeVec, secondTimeVec);
                        %
                        if areTimeBoundsCompared || (~areEndTimesDifferent &&...
                                ~areBeginTimesDifferent)                        
                            %do nothing
                        elseif areFirstTimesInsideSecond
                            isInsideVec=unionTimeVec<=firstTimeVec(2)&...
                                unionTimeVec>=firstTimeVec(1);
                            unionTimeVec=unionTimeVec(isInsideVec);
                        elseif areSecondTimesInsideFirst
                         isInsideVec=unionTimeVec<=secondTimeVec(2)&...
                                unionTimeVec>=secondTimeVec(1);
                            unionTimeVec=unionTimeVec(isInsideVec);                            
                        end
                        if areFirstTimesInsideSecond||areSecondTimesInsideFirst
                            ellTube = ellTube.interp(unionTimeVec);
                            compEllTube = compEllTube.interp(unionTimeVec);
                            [isPos, eqReportStr] = compEllTube.getFieldProjection(...
                                fieldsToCompList).isEqual(...
                                ellTube.getFieldProjection(fieldsToCompList),...
                                'maxTolerance', maxCompareTol,...
                                'checkTupleOrder',isTupleOrderChecked,...
                                reg{:});
                        else
                            isPos = false;
                            eqReportStr = 'Cannot interpolate: shifted bounds. ';
                        end
                        reportStr = [reportStr,sprintf('\n'),eqReportStr];
                    end
                end
            end
            %
            function [isSubset, indThereVec] = ...
                    fIsGridSubsetOfGrid(greaterVec, smallerVec)
                if (length(greaterVec) < length(smallerVec))
                    isSubset = false;
                else
                    [smallerMat,greaterMat]=ndgrid(smallerVec,greaterVec);
                    isCloseMat=abs(smallerMat-greaterMat)<=absTol;
                    isSubset=all(any(isCloseMat,2));
                    nFirstElems=numel(smallerVec);
                    indThereVec=zeros(1,nFirstElems);
                    for iElem=1:nFirstElems
                        indFirst=find(isCloseMat(iElem,:),1,'first');
                        if ~isempty(indFirst)
                            indThereVec(iElem)=indFirst;
                        end
                    end
                end
            end
            %
        end
    end
end