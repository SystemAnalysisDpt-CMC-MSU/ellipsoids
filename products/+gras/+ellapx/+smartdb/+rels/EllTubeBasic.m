classdef EllTubeBasic<gras.ellapx.smartdb.rels.EllTubeTouchCurveBasic
    %TestRelation Summary of this class goes here
    %   Detailed explanation goes here
    properties (Constant,Hidden)
        FCODE_Q_ARRAY
        FCODE_A_MAT
        FCODE_SCALE_FACTOR
        FCODE_M_ARRAY
    end
    methods (Static, Access=protected,Sealed)
        function [xTouchMat,xTouchOpMat]=calcTouchCurves(QArray, ...
                aMat, ltGoodDirMat)
            import gras.gen.SquareMatVector;
            %
            centRegCurve = calcCentCurve(...
                @SquareMatVector.rMultiplyByVec);
            %
            xTouchOpMat= aMat - centRegCurve;
            xTouchMat= aMat + centRegCurve;
            function curveMat = calcCentCurve(rMulByVecOp)
                tempVec = rMulByVecOp(QArray, ltGoodDirMat);
                denomVec = realsqrt(abs(dot(ltGoodDirMat, tempVec, 1)));
                curveMat = tempVec ./ denomVec(...
                    ones(1, size(QArray, 2)), :);
            end
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
        function STubeData=fromQArraysInternal(QArrayList,aMat,...
                MArrayList,timeVec,ltGoodDirArray,sTime,approxType,...
                approxSchemaName,approxSchemaDescr,calcPrecision,scaleFactorVec)
            %
            % $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011 $
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
            indSTime=find(sTime==timeVec,1,'first');
            if isempty(indSTime)
                throwerror('wrongInput:sTimeOutOfBounds',...
                    'sTime is expected to be among elements of timeVec');
            end
            %
            lsGoodDirMat=ltGoodDirArray(:,:,indSTime);
            nLDirs=length(QArrayList);
            STubeData=struct;
            %
            STubeData.scaleFactor=ones(nLDirs,1);
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
            if length(approxType) > 1
                STubeData.approxType=approxType;
            else
                STubeData.approxType=repmat(approxType,nLDirs,1);
            end
            %
            if iscell(approxSchemaName)
                STubeData.approxSchemaName=approxSchemaName;
            else
                STubeData.approxSchemaName=repmat({approxSchemaName},...
                nLDirs,1);
            end
            %
            if iscell(approxSchemaDescr)
                STubeData.approxSchemaDescr=approxSchemaDescr;
            else
                STubeData.approxSchemaDescr=repmat({approxSchemaDescr},...
                nLDirs,1);
            end
            %
            STubeData.lsGoodDirVec=cell(nLDirs,1);
            STubeData.ltGoodDirMat=cell(nLDirs,1);
            %
            STubeData.lsGoodDirNorm=zeros(nLDirs,1);
            STubeData.ltGoodDirNormVec=cell(nLDirs,1);
            STubeData.calcPrecision=repmat(calcPrecision,nLDirs,1);
            %
            STubeData.indSTime=repmat(indSTime,nLDirs,1);
            %
            for iLDir=1:1:nLDirs
                lsGoodDirVec=lsGoodDirMat(:,iLDir);
                STubeData.lsGoodDirVec{iLDir}=lsGoodDirVec;
                STubeData.lsGoodDirNorm(iLDir)=...
                    realsqrt(sum(lsGoodDirVec.*lsGoodDirVec));
                %
                ltGoodDirMat=squeeze(ltGoodDirArray(:,iLDir,:));
                %
                STubeData.ltGoodDirMat{iLDir}=ltGoodDirMat;
                %
                STubeData.ltGoodDirNormVec{iLDir}=realsqrt(sum(...
                    ltGoodDirMat.*ltGoodDirMat,1));
                %
            end
            STubeData=EllTubeBasic.scaleTubeData(STubeData,scaleFactorVec.');
            STubeData=EllTubeBasic.calcTouchCurveData(STubeData);
        end
    end
    methods (Access=protected)
        function dependencyFieldList=getTouchCurveDependencyFieldList(~)
            dependencyFieldList={'sTime','lsGoodDirVec','MArray'};
        end
        function checkTouchCurveVsQNormArray(self,tubeRel,curveRel,...
                fDistFunc,checkName,fFilterFunc)
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
                import gras.gen.SymmetricMatVector
                import modgen.common.throwerror;
                %
                actualRegPrecision = checkPrecision(...
                    @SymmetricMatVector.lrDivideVec);
                actualSvdPrecision = checkPrecision(...
                    @SymmetricMatVector.lrSvdDivideVec);
                actualPrecision = min([actualSvdPrecision, ...
                    actualRegPrecision]);
                %
                isOk = (actualPrecision <= calcPrecision);
                if ~isOk
                    throwerror('wrongInput:touchLineValueFunc',...
                        ['check [%s] has failed for %s, ',...
                        'expected precision=%d, actual precision=%d'], ...
                        checkName, fieldName, calcPrecision, ...
                        actualPrecision);
                end
                function normVal = checkPrecision(lrDivByVecOp)
                    normVec = lrDivByVecOp(QArray, xTouchCurveMat - aMat);
                    normVal = max(fDistFunc(normVec));
                end
            end
        end
        function checkIntWithinExt(self,intRel,extRel)
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
                @(x)1-x,...
                'any touch line is always outside any internal approx',...
                @(x,y)true);
            %
            extRel=fullRel.getTuplesFilteredBy('approxType',EApproxType.External);
            self.checkTouchCurveVsQNormArray(extRel,fullRel,...
                @(x)x-1,...
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
                    ndims(timeVec)==2&&size(MArray,1)==nDims&&...
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
    end
    methods
        function [ellTubeProjRel,indProj2OrigVec]=project(self,projType,...
                projMatList,fGetProjMat)
            % PROJECT - computes projection of the relation object onto given time 
            %           dependent subspase
            %           
            % 
            % Input:
            %  regular:
            %    self.
            %    projType - type of the projection.
            %        Takes the following values: 'Static'
            %                                    'DynamicAlongGoodCurve'
            %    projMatList:double[nDim, nSpDim] - matrices' array of the orthoganal  
            %             basis vectors
            %    fGetProjMat - function which creates vector of the projection 
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
            %    ellTubeProjRel:smartdb.relation.StaticRelation[1, 1]/
            %        smartdb.relation.DynamicRelation[1, 1]- projected relation
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
            %    projSpaceList = {[1 0;0 1]};
            %    projType = gras.ellapx.enums.EProjType.Static;
            %    statEllTubeProj = unionEllTube.project(projType,projSpaceList,...
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
            import gras.ellapx.uncertcalc.common.*;
            import modgen.common.throwerror;
            import gras.ellapx.common.*;
            import import gras.ellapx.enums.EProjType;
            import gras.gen.SquareMatVector;
            import gras.ellapx.smartdb.rels.EllTubeBasic;
            import gras.ellapx.proj.EllTubeStaticSpaceProjector;
            %
            ABS_TOL=1e-12;
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
                    expEigArr=gras.gen.SquareMatVector.rMultiply...
                        (projOrthMatArray,projOrthMatTransArray);
                    if ~all(abs(expEigArr-repmat(eye(size(expEigArr,1)),...
                        [1,1,size(expEigArr,3)]))<ABS_TOL)
                         throwerror('wrongInput',...
                            ['projOrthMatArray and projOrthMatTransArray',...
                            ' must be Orthogonal']);
                    end
                    %
                    tubeProjDataCMat{iGroup,iProj}.dim=...
                        repmat(size(projOrthMatArray,1),nLDirs,1);
                    tubeProjDataCMat{iGroup,iProj}.projSTimeMat=...
                        repmat({projOrthMatArray(:,:,sTime)},nLDirs,1);
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
                        tubeProjDataCMat{iGroup,iProj}.lsGoodDirOrigVec{iLDir}=...
                            STubeData.lsGoodDirVec{iOLDir};
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
    end
end