classdef AEllTubeNotTight < gras.ellapx.smartdb.rels.IEllTubeNotTight
    %
    properties (Constant,Hidden)
        FCODE_Q_ARRAY
        FCODE_A_MAT
        FCODE_SCALE_FACTOR
        FCODE_M_ARRAY
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
    end
    %
    properties (Access=protected,Constant,Hidden)
        DEFAULT_SCALE_FACTOR=1;
        N_GOOD_DIR_DISP_DIGITS=5;
        GOOD_DIR_DISP_TOL=1e-10;
    end
    %
    methods
        function [ellTubeProjRel,indProj2OrigVec]=project(self,varargin)
            import gras.ellapx.smartdb.rels.EllTubeNotTightProj
            %
            if self.getNTuples() > 0
                [rel,indProj2OrigVec]=self.projectInternal(varargin{:});
                ellTubeProjRel=EllTubeNotTightProj(rel);
            else
                ellTubeProjRel=EllTubeNotTightProj();
            end
        end
        %
        function plObj=plot(self,plObj)
            % PLOT - displays ellipsoidal tubes using the specified RelationDataPlotter
            %
            %
            % Input:
            %   regular:
            %       self:
            %       plObj: smartdb.disp.RelationDataPlotter[1,1] - plotter
            %           object used for displaying ellipsoidal tubes
            %
            % $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-12-19 $
            % $Copyright: Moscow State University,
            %            Faculty of Computational Mathematics and Computer Science,
            %            System Analysis Department 2011 $
            %
            import modgen.logging.log4j.Log4jConfigurator;
            %
            if self.getNTuples()>0
                if nargin<2
                    plObj=smartdb.disp.RelationDataPlotter;
                end
                %
                fGetFigGroupKey=@(varargin)figureGetGroupKeyFunc(self,varargin{:});
                fSetFigProp=@(varargin)figureSetPropFunc(self,varargin{:});
                %
                fGetTubeAxisDiamKey=@(varargin)axesGetKeyDiamFunc(self,varargin{:});
                fSetTubeAxisDiamProp=@(varargin)axesSetPropDiamFunc(self,varargin{:});
                %
                fGetTubeAxisTraceKey=@(varargin)axesGetKeyTraceFunc(self,varargin{:});
                fSetTubeAxisTraceProp=@(varargin)axesSetPropTraceFunc(self,varargin{:});
                %
                fPlotTubeDiam=@(varargin)plotTubeDiamFunc(self,varargin{:});
                fPlotTubeTrace=@(varargin)plotTubeTraceFunc(self,varargin{:});
                %
                plObj.plotGeneric(self,...
                    {fGetFigGroupKey},...
                    {'sTime','lsGoodDirVec'},...
                    {fSetFigProp},...
                    {},...
                    {fGetTubeAxisDiamKey,fGetTubeAxisTraceKey},...
                    {'sTime','lsGoodDirVec'},...
                    {fSetTubeAxisDiamProp,fSetTubeAxisTraceProp},...
                    {},...
                    {fPlotTubeDiam,fPlotTubeTrace},...
                    {'approxType','timeVec','QArray','MArray'});
            else
                logger=Log4jConfigurator.getLogger();
                logger.warn('nTuples=0, there is nothing to plot');
            end
        end
        %
        function thinnedEllTubeRel=thinOutTuples(self, indVec)
            import modgen.common.throwerror;
            %
            SData = self.getData();
            SThinFunResult = SData;
            timeVec = SData.timeVec{1};
            nPoints = numel(timeVec);
            if isa(indVec, 'double')
                if min(indVec) < 1 || max(indVec) > nPoints
                    throwerror('Indexes are out of range.');
                end
                isNeededIndVec = false(size(timeVec));
                isNeededIndVec(indVec) = true;
            elseif islogical(indVec)
                if numel(indVec) ~= nPoints
                    throwerror('Indexes are out of range.');
                end
                isNeededIndVec = indVec;
            else
                throwerror('indVec should be double or logical');
            end
            %
            fieldsNotToCatVec = self.getProtectedFromCutFieldList();
            fieldsToCutVec =...
                setdiff(fieldnames(SData), fieldsNotToCatVec);
            cellfun(@(field) cutStructField(field), fieldsToCutVec);
            %
            [fieldsFromCVec,fieldsToCVec]=self.getSTimeFieldList();
            fieldsToCVec=intersect(fieldsToCVec,fieldnames(SData),'stable');
            fieldsFromCVec=intersect(fieldsFromCVec,fieldnames(SData),'stable');
            cellfun(@cutStructSTimeField,fieldsToCVec,fieldsFromCVec);
            %
            SThinFunResult.lsGoodDirNorm =...
                cell2mat(SThinFunResult.lsGoodDirNorm);
            SThinFunResult.sTime(:) = timeVec(find(isNeededIndVec, 1));
            SThinFunResult.indSTime(:) = 1;
            %
            thinnedEllTubeRel = self.createInstance(SThinFunResult);
            %
            function cutStructSTimeField(fieldNameTo, fieldNameFrom)
                SThinFunResult.(fieldNameTo) =...
                    cellfun(@(field) field(:, 1),...
                    SThinFunResult.(fieldNameFrom),...
                    'UniformOutput', false);
            end
            %
            function cutResObj = getCutObj(whatToCutObj, isCutTimeVec)
                switch ndims(whatToCutObj)
                    case 1
                        cutResObj = whatToCutObj(isCutTimeVec);
                    case 2
                        cutResObj = whatToCutObj(:, isCutTimeVec);
                    case 3
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
        %
        function catEllTubeRel=cat(self, newEllTubeRel)
            SDataFirst = self.getData();
            SDataSecond = newEllTubeRel.getData();
            SCatFunResult = SDataFirst;
            %
            fieldsNotToCatVec = self.getProtectedFromCutFieldList();
            fieldsToCatVec =...
                setdiff(fieldnames(SDataFirst), fieldsNotToCatVec);
            cellfun(@(field) catStructField(field), fieldsToCatVec);
            catEllTubeRel = self.createInstance(SCatFunResult);
            %
            function catStructField(fieldName)
                SCatFunResult.(fieldName) =...
                    cellfun(@(firstStructFieldVal, secondStructFieldVal)...
                    cat(ndims(firstStructFieldVal), firstStructFieldVal,...
                    secondStructFieldVal), SDataFirst.(fieldName),...
                    SDataSecond.(fieldName), 'UniformOutput', false);
            end
        end
        %
        function cutEllTubeRel=cut(self, cutTimeVec)
            import modgen.common.throwerror;
            %
            if numel(cutTimeVec) == 1
                cutTimeVec = [cutTimeVec(1) cutTimeVec(1)];
            end
            if numel(cutTimeVec) ~= 2
                throwerror('wrongInput', ['input vector should ',...
                    'contain 1 or 2 elements.']);
            end
            cutStartTime = cutTimeVec(1);
            cutEndTime = cutTimeVec(2);
            if cutStartTime > cutEndTime
                throwerror('wrongInput', 's0 must be LEQ than s1.');
            end
            timeVec = self.timeVec{1};
            sysStartTime = timeVec(1);
            sysEndTime = timeVec(end);
            if sysStartTime < sysEndTime
                if cutStartTime < sysStartTime ||...
                        cutStartTime > sysEndTime ||...
                        cutEndTime < sysStartTime ||...
                        cutEndTime > sysEndTime
                    throwerror('wrongInput', 'wrong input format.');
                end
            else
                if cutStartTime > sysStartTime ||...
                        cutStartTime < sysEndTime ||...
                        cutEndTime > sysStartTime ||...
                        cutEndTime < sysEndTime
                    throwerror('wrongInput', 'wrong input format.');
                end
            end
            if cutTimeVec(1) == cutTimeVec(2)
                indClosestVec = find(timeVec <= cutStartTime, 1, 'last');
                isSysNewTimeIndVec = false(size(timeVec));
                isSysNewTimeIndVec(indClosestVec) = true;
            else
                isSysTimeLowerVec = timeVec < cutStartTime;
                isSysTimeGreaterVec = timeVec > cutEndTime;
                [~, unVec, ~] = unique(timeVec);
                isSysNewTimeIndVec = false(size(timeVec));
                isSysNewTimeIndVec(unVec) = true;
                isSysNewTimeIndVec = isSysNewTimeIndVec &...
                    ~(isSysTimeLowerVec | isSysTimeGreaterVec);
            end
            %
            cutEllTubeRel =...
                self.thinOutTuples(isSysNewTimeIndVec);
        end
        %
        function scale(self,fCalcFactor,fieldNameList)
            scaleFactorVec=self.applyTupleGetFunc(fCalcFactor,...
                fieldNameList);
            self.setData(...
                self.scaleTubeData(self.getData(),scaleFactorVec));
        end
        %
        function ellTubeProjRel=projectToOrths(self,indVec,projType)
            %
            % PROJECTTOORTHS - project elltube onto subspace defined by
            % vectors of standart basis with indices specified in indVec
            %
            % Input:
            %   regular:
            %       self: gras.ellapx.smartdb.rels.EllTube[1, 1] - elltube
            %           object
            %       indVec: double[1, nProjDims] - indices specifying a subset of
            %           standart basis
            %   optional:
            %       projType: gras.ellapx.enums.EProjType[1, 1] -  type of
            %           projection
            %
            % Output:
            %   regular:
            %       ellTubeProjRel: gras.ellapx.smartdb.rels.EllTubeProj[1, 1] - 
            %           elltube projection
            %
            % Example:
            %   ellTubeProjRel = ellTubeRel.projectToOrths([1,2])
            %   projType = gras.ellapx.enums.EProjType.DynamicAlongGoodCurve
            %   ellTubeProjRel = ellTubeRel.projectToOrths([3,4,5], projType)
            %
            % $Author: Ivan Menshikov <ivan.v.menshikov@gmail.com>$
            % $Copyright: Moscow State University,
            %             Faculty of Computational
            %             Mathematics and Computer Science,
            %             System Analysis Department 2013 $
            %
            %
            dim = min(self.dim);
            %
            if nargin < 3
                projType = gras.ellapx.enums.EProjType.Static;
            end
            %
            projMat = eye(dim);
            projMat = projMat(:,indVec).';
            ellTubeProjRel = self.project(projType,{projMat},@fGetProjMat);
            %
            function [projOrthMatArray,projOrthMatTransArray]=...
                    fGetProjMat(projMat,timeVec,varargin)
                nPoints=length(timeVec);
                projOrthMatArray=repmat(projMat,[1,1,nPoints]);
                projOrthMatTransArray=repmat(projMat.',[1,1,nPoints]);
            end
        end
        %
        function [apprEllMat timeVec]=getEllArray(self, approxType)
            import gras.ellapx.smartdb.F;
            %
            SData = self.getTuplesFilteredBy(F.APPROX_TYPE, approxType);
            nTuples = SData.getNTuples();
            if nTuples > 0
                apprEllMat = ellipsoid(...
                    cat(3,SData.aMat{1:nTuples}),...
                    cat(4,SData.QArray{1:nTuples}))';
            else
                apprEllMat = [];
            end
            if nargout > 1
                if ~isempty(SData.timeVec)
                    timeVec = SData.timeVec{1};
                else
                    timeVec = [];
                end
            end
        end
    end
    %
    methods (Static)
        function STubeData=scaleTubeData(STubeData,scaleFactorVec)
            import gras.gen.SquareMatVector;
            %
            scaleQFactorVec=scaleFactorVec.*scaleFactorVec;
            scaleQFactorList=num2cell(scaleQFactorVec);
            %
            STubeData.QArray=cellfun(@times,STubeData.QArray,...
                scaleQFactorList,'UniformOutput',false);
            STubeData.MArray=cellfun(@times,STubeData.MArray,...
                scaleQFactorList,'UniformOutput',false);
            %
            STubeData.QArray=cellfun(@SquareMatVector.makeSymmetric,...
                STubeData.QArray,'UniformOutput',false);
            %
            STubeData.scaleFactor=STubeData.scaleFactor.*scaleFactorVec;
        end
    end
    %
    methods (Access=protected)
        function fieldList=getProtectedFromCutFieldList(~)
            import gras.ellapx.smartdb.F
            %
            FIELDS={'APPROX_SCHEMA_DESCR';'DIM';'APPROX_SCHEMA_NAME';...
                'APPROX_TYPE';'CALC_PRECISION';'IND_S_TIME';...
                'LS_GOOD_DIR_NORM';'LS_GOOD_DIR_VEC';'S_TIME';...
                'SCALE_FACTOR'};
            %
            fieldList=F.getNameList(FIELDS);
        end
        %
        function [fieldListFrom,fieldListTo]=getSTimeFieldList(~)
            import gras.ellapx.smartdb.F
            %
            FIELDS_FROM = {'LT_GOOD_DIR_MAT';'LT_GOOD_DIR_NORM_VEC'};
            FIELDS_TO = {'LS_GOOD_DIR_VEC';'LS_GOOD_DIR_NORM'};
            %
            fieldListFrom=F.getNameList(FIELDS_FROM);
            fieldListTo=F.getNameList(FIELDS_TO);
        end
        %
        function depFieldList=getProblemDependencyFieldList(~)
            depFieldList={'MArray'};
        end
        %
        function fieldNameList=getProjectionDependencyFieldList(~)
            fieldNameList={'timeVec','sTime','dim','indSTime'};
        end
        %
        function strVal=goodDirProp2Str(~,lsGoodDirVec,sTime)
            import gras.ellapx.smartdb.rels.AEllTubeNotTight;
            %
            dispDigits=AEllTubeNotTight.N_GOOD_DIR_DISP_DIGITS;
            dispTol=AEllTubeNotTight.GOOD_DIR_DISP_TOL;
            lsGoodDirVec(abs(lsGoodDirVec)<dispTol)=0;
            strVal = sprintf('lsGoodDirVec=%s, sTime=%f',...
                mat2str(lsGoodDirVec,dispDigits),sTime);
                end
        %
        function figureGroupKeyName=figureGetGroupKeyFunc(self,sTime,lsGoodDirVec)
            figureGroupKeyName=sprintf(...
                'Ellipsoidal tube characteristics for %s',...
                self.goodDirProp2Str(lsGoodDirVec,sTime));
        end
        %
        function figureSetPropFunc(~,hFigure,figureName,~)
            set(hFigure,'NumberTitle','off','WindowStyle','docked',...
                'RendererMode','manual','Renderer','OpenGL',...
                'Name',figureName);
        end
        %
        function axesName=axesGetKeyDiamFunc(self,sTime,lsGoodDirVec)
            axesName=sprintf('Diameters for\n %s',...
                self.goodDirProp2Str(lsGoodDirVec,sTime));
        end
        %
        function axesName=axesGetKeyTraceFunc(self,sTime,lsGoodDirVec)
            axesName=sprintf('Ellipsoid matrix traces for\n %s',...
                self.goodDirProp2Str(lsGoodDirVec,sTime));
        end
        %
        function hVec=axesSetPropBasicFunc(~,hAxes,axesName,yLabel)
            title(hAxes,axesName);
            xLabel='time';
            %
            set(hAxes,'XLabel',...
                text('String',xLabel,'Interpreter','tex','Parent',hAxes));
            set(hAxes,'YLabel',...
                text('String',yLabel,'Interpreter','tex','Parent',hAxes));
            set(hAxes,'xtickmode','auto',...
                'ytickmode','auto','xgrid','on','ygrid','on');
            hVec=[];
        end
        %
        function hVec=axesSetPropDiamFunc(self,hAxes,axesName)
            hVec=axesSetPropBasicFunc(self,hAxes,axesName,'diameter');
        end
        %
        function hVec=axesSetPropTraceFunc(self,hAxes,axesName)
            hVec=axesSetPropBasicFunc(self,hAxes,axesName,'trace');
        end
        %
        function hVec=plotTubeTraceFunc(~,hAxes,approxType,timeVec,...
                QArray,MArray)
            %
            import gras.ellapx.enums.EApproxType;
            import modgen.common.throwerror;
            %
            switch approxType
                case EApproxType.Internal
                    tubeArgList={'g-.'};
                case EApproxType.External
                    tubeArgList={'b-.'};
                otherwise
                    throwerror('wrongInput',...
                        'Approximation type %s is not supported');
            end
            %
            hQVec=plotTrace(QArray,'tube',tubeArgList{:});
            if approxType == EApproxType.Internal
                hMVec=plotTrace(MArray,'reg','r-');
            else
                hMVec=[];
            end
            %
            hVec=[hQVec,hMVec];
            %
            axis(hAxes,'tight');
            axis(hAxes,'normal');
            hold(hAxes,'on');
            %
            function hVec=plotTrace(InpArray,namePrefix,lineSpec,varargin)
                import modgen.common.throwerror;
                import gras.gen.SquareMatVector;
                import gras.geom.ell.ellvolume;
                %
                traceVec=SquareMatVector.evalMFunc(@trace,InpArray);
                hVec=plot(hAxes,timeVec,traceVec,lineSpec,...
                    varargin{:},...
                    'DisplayName',...
                    [namePrefix,', trace, ',char(approxType)]);
            end
        end
        %
        function hVec=plotTubeDiamFunc(~,hAxes,approxType,timeVec,...
                QArray,MArray)
            %
            import gras.ellapx.enums.EApproxType;
            import modgen.common.throwerror;
            %
            switch approxType
                case EApproxType.Internal
                    tubeArgList={'g-.'};
                case EApproxType.External
                    tubeArgList={'b-.'};
                otherwise
                    throwerror('wrongInput',...
                        'Approximation type %s is not supported');
            end
            %
            hQVec=plotEig(QArray,'tube',tubeArgList{:});
            %
            if approxType==EApproxType.Internal
                hMVec=plotEig(MArray,'reg','r-');
            else
                hMVec=[];
            end
            %
            hVec=[hQVec,hMVec];
            %
            axis(hAxes,'tight');
            axis(hAxes,'normal');
            hold(hAxes,'on');
            %
            function hVec=plotEig(InpArray,namePrefix,lineSpec,varargin)
                import modgen.common.throwerror;
                %
                nTimePoints=size(InpArray,3);
                eMat=zeros(size(InpArray,1),nTimePoints);
                oArray=get(hAxes,'UserData');
                if isempty(oArray)
                    oArray=zeros(size(InpArray));
                    for iTime=1:nTimePoints
                        inpMat=InpArray(:,:,iTime);
                        oMat=gras.la.matorth(inpMat);
                        oArray(:,:,iTime)=oMat;
                    end
                    set(hAxes,'UserData',oArray);
                end
                %
                for iTime=1:nTimePoints
                    oMat=oArray(:,:,iTime);
                    inpMat=InpArray(:,:,iTime);
                    eSquaredVec=sum((inpMat*oMat).*oMat,1);
                    if any(eSquaredVec<0)
                        throwerror('wrongInput',...
                            'Oops, we shouldn''t be here');
                    end
                    eMat(:,iTime)=realsqrt(eSquaredVec);
                end
                %
                eMinVec=min(eMat,[],1);
                eMaxVec=max(eMat,[],1);
                hVec(2)=plot(hAxes,timeVec,eMaxVec,lineSpec,...
                    varargin{:},...
                    'DisplayName',...
                    sprintf('%s_eig_max_%s',namePrefix,...
                    char(approxType)));
                hVec(1)=plot(hAxes,timeVec,eMinVec,lineSpec,...
                    varargin{:},...
                    'DisplayName',...
                    sprintf('%s_eig_min_%s',namePrefix,...
                    char(approxType)));
            end
        end
        %
        function [ellTubeProjRel,indProj2OrigVec]=projectInternal(self,...
                projType,projMatList,fGetProjMat)
            %
            import smartdb.relations.DynamicRelation;
            %
            projDepFieldNameList=self.getProjectionDependencyFieldList();
            [SUData,~,~,indForwardVec,indBackwardVec]=...
                self.getUniqueData('fieldNameList',projDepFieldNameList);
            %
            nProj=length(projMatList);
            nGroups=length(indForwardVec);
            STubeData=self.getData();
            %
            tubeProjDataCMat=cell(nGroups,nProj);
            indProj2OrigCVec=cell(nGroups);
            %
            for iGroup=1:nGroups
                timeVec=SUData.timeVec{iGroup};
                sTime=SUData.sTime(iGroup);
                indSTime=SUData.indSTime(iGroup);
                dim=SUData.dim;
                indLDirs=find(indBackwardVec==iGroup);
                %
                for iProj=nProj:-1:1
                    tubeProjDataCMat{iGroup,iProj}=...
                        self.buildOneProjection(STubeData,...
                        projMatList{iProj},fGetProjMat,projType,...
                        timeVec,sTime,indSTime,dim,indLDirs);
                end
                %
                indProj2OrigCVec{iGroup}=indLDirs;
            end
            ellTubeProjRel=DynamicRelation.fromStructList(tubeProjDataCMat);
            %
            indProj2OrigCMat=repmat(indProj2OrigCVec,1,nProj);
            indProj2OrigVec=vertcat(indProj2OrigCMat{:});
        end
        %
        function SProjData=buildOneProjection(~,STubeData,projMat,...
                fGetProjMat,projType,timeVec,sTime,indSTime,dim,indLDirs)
            %
            import import gras.gen.SquareMatVector
            %
            nLDirs=length(indLDirs);
            %
            SProjData=struct;
            SProjData.dim=repmat(size(projMat,1),nLDirs,1);
            SProjData.projSTimeMat=repmat({projMat},nLDirs,1);
            SProjData.projType=repmat(projType,nLDirs,1);
            SProjData.QArray=cell(nLDirs,1);
            SProjData.aMat=cell(nLDirs,1);
            SProjData.MArray=cell(nLDirs,1);
            SProjData.sTime=repmat(sTime,nLDirs,1);
            SProjData.indSTime=repmat(indSTime,nLDirs,1);
            SProjData.timeVec=repmat({timeVec},nLDirs,1);
            SProjData.lsGoodDirVec=cell(nLDirs,1);
            SProjData.ltGoodDirMat=cell(nLDirs,1);
            SProjData.lsGoodDirNorm=zeros(nLDirs,1);
            SProjData.ltGoodDirNormVec=cell(nLDirs,1);
            SProjData.lsGoodDirNormOrig=zeros(nLDirs,1);
            SProjData.ltGoodDirNormOrigVec=cell(nLDirs,1);
            SProjData.lsGoodDirOrigVec=cell(nLDirs,1);
            SProjData.approxSchemaName=...
                STubeData.approxSchemaName(indLDirs);
            SProjData.approxSchemaDescr=...
                STubeData.approxSchemaDescr(indLDirs);
            SProjData.approxType=STubeData.approxType(indLDirs);
            SProjData.calcPrecision=STubeData.calcPrecision(indLDirs);
            SProjData.scaleFactor=STubeData.scaleFactor(indLDirs);
            %
            [projOrthMatArray,projOrthMatTransArray]=...
                fGetProjMat(projMat,timeVec,sTime,dim,indSTime);
            projOrthSTimeMat=projOrthMatArray(:,:,indSTime);
            %
            for iLDir=1:nLDirs
                iOLDir=indLDirs(iLDir);
                %
                SProjData.ltGoodDirMat{iLDir}=SquareMatVector.rMultiplyByVec(...
                    projOrthMatArray,STubeData.ltGoodDirMat{iOLDir});
                %
                SProjData.QArray{iLDir}=SquareMatVector.rMultiply(...
                    projOrthMatArray,STubeData.QArray{iOLDir},...
                    projOrthMatTransArray);
                SProjData.QArray{iLDir}=SquareMatVector.makeSymmetric(...
                    SProjData.QArray{iLDir});
                %
                SProjData.aMat{iLDir}=SquareMatVector.rMultiplyByVec(...
                    projOrthMatArray,STubeData.aMat{iOLDir});
                %
                SProjData.MArray{iLDir}=SquareMatVector.rMultiply(...
                    projOrthMatArray,STubeData.MArray{iOLDir},...
                    projOrthMatTransArray);
                SProjData.MArray{iLDir}=SquareMatVector.makeSymmetric(...
                    SProjData.MArray{iLDir});
                %
                % the following statements are only valid for orthogonal projections
                %
                SProjData.ltGoodDirMat{iLDir}=SquareMatVector.rMultiplyByVec(...
                    projOrthMatArray,STubeData.ltGoodDirMat{iOLDir});
                SProjData.lsGoodDirVec{iLDir}=...
                    projOrthSTimeMat*STubeData.lsGoodDirVec{iOLDir};
                %
                lsGoodDirVec=SProjData.lsGoodDirVec{iLDir};
                ltGoodDirMat=SProjData.ltGoodDirMat{iLDir};
                %
                SProjData.lsGoodDirNorm(iLDir)=...
                    realsqrt(sum(lsGoodDirVec.*lsGoodDirVec));
                SProjData.ltGoodDirNormVec{iLDir}=...
                    realsqrt(sum(ltGoodDirMat.*ltGoodDirMat,1));
                %
                SProjData.lsGoodDirOrigVec{iOLDir}=...
                    STubeData.lsGoodDirVec{iOLDir};
                SProjData.lsGoodDirNormOrig(iLDir)=...
                    STubeData.lsGoodDirNorm(iOLDir);
                SProjData.ltGoodDirNormOrigVec{iLDir}=...
                    STubeData.ltGoodDirNormVec{iOLDir};
            end
        end
        %
        function checkDataConsistency(self)
            import modgen.common.throwerror;
            import gras.gen.SquareMatVector;
            import modgen.common.num2cell;
            import gras.ellapx.enums.EApproxType;
            %
            TS_CHECK_TOL=1e-14;
            %
            % Check internal tube consistency
            %
            checkFieldList={'QArray','aMat','scaleFactor','MArray',...
                'dim','sTime','approxSchemaName','approxSchemaDescr',...
                'approxType','timeVec','calcPrecision','indSTime',...
                'ltGoodDirMat','lsGoodDirVec','ltGoodDirNormVec',...
                'lsGoodDirNorm'};
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
            % Check that int tubes lie within ext tubes
            %
            self.checkIntWithinExt();
            %
            % Check for consistency between ls and lt fields
            %
            fCheck=@(x,y,z)max(abs(x-y(:,z)))<=TS_CHECK_TOL;
            indSTimeList=num2cell(self.indSTime);
            self.checkSVsTConsistency(self.lsGoodDirVec,...
                self.ltGoodDirMat,indSTimeList,'lsGoodDirVec',...
                'ltGoodDirMat',fCheck);
            self.checkSVsTConsistency(num2cell(self.lsGoodDirNorm),...
                self.ltGoodDirNormVec,indSTimeList,'lsGoodDirNorm',...
                'ltGoodDirNormVec',fCheck);
            %
            function [isTupleOk,errTagStr,reasonStr]=checkTuple(...
                    QArray,aMat,scaleFactor,MArray,...
                    dim,sTime,approxSchemaName,approxSchemaDescr,...
                    approxType,timeVec,calcPrecision,indSTime,...
                    ltGoodDirMat,lsGoodDirVec,ltGoodDirNormVec,...
                    lsGoodDirNorm)
                %
                isTupleOk=false;
                nPoints=size(timeVec,2);
                nDims=size(QArray,1);
                %
                % Check for positive (semi-)definiteness
                %
                isOk=gras.gen.SquareMatVector.evalMFunc(...
                    @(x)gras.la.ismatposdef(x,calcPrecision),QArray);
                %
                if ~all(isOk)
                    errTagStr='QArrayNotPos';
                    reasonStr='QArray is not positively defined';
                    return;
                end
                %
                isOk=gras.gen.SquareMatVector.evalMFunc(...
                    @(x)gras.la.ismatposdef(x,calcPrecision,true),MArray);
                %
                if ~all(isOk)
                    errTagStr='MArrayNeg';
                    reasonStr='MArray is negatively defined';
                    return;
                end
                %
                % Check for consistency between sizes
                %
                isOk=...
                    size(QArray,2)==nDims&&...
                    size(QArray,3)==nPoints&&...
                    size(MArray,1)==nDims&&...
                    size(MArray,2)==nDims&&...
                    size(MArray,3)==nPoints&&...
                    size(aMat,1)==nDims&&...
                    size(aMat,2)==nPoints&&...
                    ismatrix(timeVec)&&...
                    size(timeVec,1)==1&&...
                    size(ltGoodDirMat,1)==nDims&&...
                    size(ltGoodDirMat,2)==nPoints&&...
                    size(ltGoodDirNormVec,1)==1&&...
                    size(ltGoodDirNormVec,2)==nPoints&&...
                    size(lsGoodDirVec,1)==nDims&&...
                    numel(lsGoodDirNorm)==1&&...
                    numel(indSTime)==1&&...
                    numel(scaleFactor)==1&&...
                    numel(dim)==1&&...
                    numel(sTime)==1&&...
                    numel(calcPrecision)==1&&...
                    ismatrix(approxSchemaName)&&...
                    size(approxSchemaName,1)==1&&...
                    ismatrix(approxSchemaDescr)&&...
                    size(approxSchemaDescr,1)==1&&...
                    numel(approxType)==1&&...
                    dim==nDims;
                %
                if ~isOk
                    reasonStr='Fields have inconsistent sizes';
                    errTagStr='badSize';
                    return;
                end
                %
                % Check for consistency between ltGoodDirMat and ltGoodDirNormVec
                %
                ltGoodDirNormExpVec=realsqrt(sum(ltGoodDirMat.*ltGoodDirMat,1));
                if ~areArraysEqual(ltGoodDirNormVec, ltGoodDirNormExpVec)
                    reasonStr='Failed check for ltGoodDirMat and ltGoodDirNormVec';
                    errTagStr='wrongInput';
                    return;
                end
                %
                % check for a consistency between lsGoodDirVec and lsGoodDirNorm
                %
                lsGoodDirNormExp=realsqrt(sum(lsGoodDirVec.*lsGoodDirVec,1));
                if ~areArraysEqual(lsGoodDirNorm, lsGoodDirNormExp)
                    reasonStr='Failed check for lsGoodDirVec and lsGoodDirNorm';
                    errTagStr='wrongInput';
                    return;
                end
                %
                isTupleOk=true;
                errTagStr='';
                reasonStr='';
            end
            %
            function isOk = areArraysEqual(aArray, bArray)
                isOk = abs(max(aArray(:) - bArray(:))) < TS_CHECK_TOL;
            end
        end
        %
        function checkIntWithinExt(self)
            import gras.ellapx.enums.EApproxType
            %
            rel=smartdb.relations.DynamicRelation(self);
            intRel=rel.getTuplesFilteredBy('approxType',EApproxType.Internal);
            extRel=rel.getTuplesFilteredBy('approxType',EApproxType.External);
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
            %
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
        %
        function checkSVsTConsistency(~,lsList,ltList,indList,...
                lsName,ltName,fCheck)
            import modgen.common.throwerror;
            %
            if ~isempty(indList)
                isOkVec=cellfun(fCheck,lsList,ltList,indList);
                if ~all(isOkVec)
                    throwerror('wrongInput',['tuples with indices %s ',...
                        'have inconsistent %s and %s'],...
                        lsName,ltName,mat2str(find(~isOkVec)));
                end
            end
        end
    end
end

