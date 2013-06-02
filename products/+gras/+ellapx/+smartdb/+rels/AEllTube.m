classdef AEllTube < gras.ellapx.smartdb.rels.AEllTubeNotTight & ...
        gras.ellapx.smartdb.rels.IEllTube
    %
    properties (Constant,Hidden)
        FCODE_X_TOUCH_CURVE_MAT
        FCODE_X_TOUCH_OP_CURVE_MAT
        FCODE_XS_TOUCH_VEC
        FCODE_XS_TOUCH_OP_VEC
    end
    %
    methods
        function [ellTubeProjRel,indProj2OrigVec]=project(self,varargin)
            import gras.ellapx.smartdb.rels.EllTubeProj
            %
            if self.getNTuples() > 0
                [SProjData,indProj2OrigVec]=self.projectInternal(varargin{:});
                ellTubeProjRel=EllTubeProj(SProjData);
            else
                ellTubeProjRel=EllTubeProj();
            end
        end
    end
    %
    methods (Static)
        function STubeData=scaleTubeData(STubeData,scaleFactorVec)
            import gras.ellapx.smartdb.rels.AEllTube;
            %
            STubeData=scaleTubeData@gras.ellapx.smartdb.rels.AEllTubeNotTight(...
                STubeData,scaleFactorVec);
            STubeData=AEllTube.calcTouchCurveData(STubeData);
        end
        %
        function STubeData=calcTouchCurveData(STubeData)
            nLDirs=length(STubeData.QArray);
            %
            STubeData.xsTouchVec=cell(nLDirs,1);
            STubeData.xsTouchOpVec=cell(nLDirs,1);
            STubeData.xTouchCurveMat=cell(nLDirs,1);
            STubeData.xTouchOpCurveMat=cell(nLDirs,1);
            %
            for iLDir=1:nLDirs
                indSTime=STubeData.indSTime(iLDir);
                [STubeData.xTouchCurveMat{iLDir},...
                    STubeData.xTouchOpCurveMat{iLDir}]=calcOneTouchCurve(...
                    STubeData.QArray{iLDir},STubeData.aMat{iLDir},...
                    STubeData.ltGoodDirMat{iLDir});
                %
                STubeData.xsTouchVec{iLDir}=...
                    STubeData.xTouchCurveMat{iLDir}(:,indSTime);
                STubeData.xsTouchOpVec{iLDir}=...
                    STubeData.xTouchOpCurveMat{iLDir}(:,indSTime);
            end
            %
            function [xTouchMat,xTouchOpMat]=calcOneTouchCurve(QArray,aMat,...
                    ltGoodDirMat)
                %
                import gras.gen.SquareMatVector;
                %
                Qsize=size(QArray);
                tmp=SquareMatVector.rMultiplyByVec(QArray,ltGoodDirMat);
                denominator=realsqrt(abs(sum(tmp.*ltGoodDirMat)));
                temp=tmp./denominator(ones(1,Qsize(2)),:);
                xTouchOpMat=aMat-temp;
                xTouchMat=aMat+temp;
            end
        end
    end
    %
    methods (Access=protected)
        function fieldList=getProtectedFromCutFieldList(self)
            import gras.ellapx.smartdb.F
            %
            FIELDS={'XS_TOUCH_OP_VEC';'XS_TOUCH_VEC'};
            %
            fieldList=getProtectedFromCutFieldList@...
                gras.ellapx.smartdb.rels.AEllTubeNotTight(self);
            %
            fieldList=[fieldList;F.getNameList(FIELDS)];
        end
        %
        function [fieldListFrom,fieldListTo]=getSTimeFieldList(self)
            import gras.ellapx.smartdb.F
            %
            FIELDS_FROM = {'X_TOUCH_CURVE_MAT';'X_TOUCH_OP_CURVE_MAT'};
            FIELDS_TO = {'XS_TOUCH_VEC';'XS_TOUCH_OP_VEC'};
            %
            [fieldListFrom,fieldListTo]=getSTimeFieldList@...
                gras.ellapx.smartdb.rels.AEllTubeNotTight(self);
            %
            fieldListFrom=[fieldListFrom;F.getNameList(FIELDS_FROM)];
            fieldListTo=[fieldListTo;F.getNameList(FIELDS_TO)];
        end
        %
        function SProjData=buildOneProjection(self,STubeData,projMat,...
                fGetProjMat,projType,timeVec,sTime,indSTime,dim,indLDirs)
            %
            import import gras.gen.SquareMatVector
            %
            nLDirs=length(indLDirs);
            %
            SProjData=buildOneProjection@gras.ellapx.smartdb.rels.AEllTubeNotTight(...
                self,STubeData,projMat,fGetProjMat,projType,timeVec,...
                sTime,indSTime,dim,indLDirs);
            %
            SProjData.xTouchCurveMat=cell(nLDirs,1);
            SProjData.xTouchOpCurveMat=cell(nLDirs,1);
            SProjData.xsTouchVec=cell(nLDirs,1);
            SProjData.xsTouchOpVec=cell(nLDirs,1);
            %
            [projOrthMatArray,projOrthMatTransArray]=...
                fGetProjMat(projMat,timeVec,sTime,dim,indSTime);
            projOrthSTimeMat=projOrthMatArray(:,:,indSTime);
            %
            for iLDir=1:nLDirs
                iOLDir=indLDirs(iLDir);
                %
                SProjData.xTouchCurveMat{iLDir}=SquareMatVector.rMultiplyByVec(...
                    projOrthMatArray,STubeData.xTouchCurveMat{iOLDir});
                SProjData.xTouchOpCurveMat{iLDir}=SquareMatVector.rMultiplyByVec(...
                    projOrthMatArray,STubeData.xTouchOpCurveMat{iOLDir});
                SProjData.xsTouchVec{iLDir}=...
                    projOrthSTimeMat*STubeData.xsTouchVec{iOLDir};
                SProjData.xsTouchOpVec{iLDir}=...
                    projOrthSTimeMat*STubeData.xsTouchOpVec{iOLDir};
            end
        end
        %
        function dependencyFieldList=getTouchCurveDependencyFieldList(~)
            dependencyFieldList={'sTime','lsGoodDirVec','MArray'};
        end
        %
        function checkFieldList=getTouchCurveDependencyCheckedFieldList(~)
            checkFieldList={'xTouchCurveMat','xTouchOpCurveMat',...
                'xsTouchVec','xsTouchOpVec'};
        end
        %
        function fCheckFieldTransfList=getTouchCurveDependencyCheckTransFuncList(~)
            fCheckFieldTransfList={...
                @(fieldVal,scaleFactor,aMat,indSTime)(fieldVal-aMat)./scaleFactor,...
                @(fieldVal,scaleFactor,aMat,indSTime)(fieldVal-aMat)./scaleFactor,...
                @(fieldVal,scaleFactor,aMat,indSTime)(fieldVal-aMat(:,indSTime))./scaleFactor,...
                @(fieldVal,scaleFactor,aMat,indSTime)(fieldVal-aMat(:,indSTime))./scaleFactor};
        end
        %
        function checkTouchCurveIndependence(self)
            rel=smartdb.relations.DynamicRelation(self);
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
                                actTol=max(reshape(abs(valList{iTuple}{1}-...
                                    valList{iTuple}{iVal}),[],1));
                                expTol=(tolVec(1)+tolVec(iVal));
                                isOk=actTol<=expTol;
                                if ~isOk
                                    optMsg=sprintf(['actual tolerance=%g',...
                                        ', expected tolerance=%g'],actTol,...
                                        expTol);
                                    throwError('value',fieldName,optMsg);
                                end
                            end
                        end
                    end
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
        %
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
        end
        %
        function checkTouchCurveVsQNormArray(~,tubeRel,curveRel,...
                fTolFunc,checkName,fFilterFunc)
            %
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
            %
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
        %
        function checkDataConsistency(self)
            import modgen.common.throwerror;
            import gras.gen.SquareMatVector;
            import modgen.common.num2cell;
            %
            TS_CHECK_TOL=1e-14;
            %
            checkDataConsistency@gras.ellapx.smartdb.rels.AEllTubeNotTight(self);
            %
            % Check internal tube consistency
            %
            checkFieldList={'QArray','timeVec','indSTime','xTouchCurveMat',...
                'xTouchOpCurveMat','xsTouchVec','xsTouchOpVec'};
            %
            [isOkList,errTagList,reasonList]=self.applyTupleGetFunc(...
                @checkTuple,checkFieldList,'UniformOutput',false);
            %
            isOkVec=vertcat(isOkList{:});
            if ~all(isOkVec)
                indFirst=find(~isOkVec,1,'first');
                throwerror(['wrongInput:',errTagList{indFirst}],...
                    ['Tuples with indices %s have inconsistent ',...
                    'values, reason: ',reasonList{indFirst}],...
                    mat2str(find(~isOkVec)));
            end
            %
            % Check for consistency between ls and lt fields
            %
            fCheck=@(x,y,z)max(abs(x-y(:,z)))<=TS_CHECK_TOL;
            indSTimeList=num2cell(self.indSTime);
            self.checkSVsTConsistency(self.xsTouchVec,...
                self.xTouchCurveMat,indSTimeList,'xsTouchVec',...
                'xTouchCurveMat',fCheck);
            self.checkSVsTConsistency(self.xsTouchOpVec,...
                self.xTouchOpCurveMat,indSTimeList,'xsOpTouchVec',...
                'xTouchOpCurveMat',fCheck);
            %
            % Check that touch curve depends only on sTime and lsGoodDirVec
            %
            self.checkTouchCurveIndependence();
            %
            % Check that touch lines lie within the tubes
            %
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
            %
            function [isTupleOk,errTagStr,reasonStr]=checkTuple(QArray,...
                    timeVec,~,xTouchCurveMat,xTouchOpCurveMat,...
                    xsTouchVec,xsTouchOpVec)
                %
                isTupleOk = false;
                nPoints=size(timeVec,2);
                nDims=size(QArray,1);
                %
                % Check for consistency between sizes
                %
                isOk=...
                    size(xTouchCurveMat,1)==nDims&&...
                    size(xTouchCurveMat,2)==nPoints&&...
                    size(xTouchOpCurveMat,2)==nPoints&&...
                    size(xsTouchVec,1)==nDims&&...
                    size(xsTouchOpVec,1)==nDims;
                %
                if ~isOk
                    reasonStr='Fields have inconsistent sizes';
                    errTagStr='badSize';
                    return;
                end
                %
                isTupleOk=true;
                errTagStr='';
                reasonStr='';
            end
        end
    end
end

