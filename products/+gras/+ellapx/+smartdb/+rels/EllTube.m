classdef EllTube<gras.ellapx.smartdb.rels.ATypifiedAdjustedRel&...
        gras.ellapx.smartdb.rels.EllTubeBasic&...
        gras.ellapx.smartdb.rels.AEllTubeProjectable
    % EllTube - class which keeps ellipsoidal tubes
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
    %                 (external, internal, not defined)
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
    %
    %   TODO: correct description of the fields in gras.ellapx.smartdb.rels.EllTube
    methods(Access=protected)
        function changeDataPostHook(self)
            self.checkDataConsistency();
        end
    end
    properties (GetAccess=private,Constant)
        DEFAULT_SCALE_FACTOR=1;
    end
    methods (Access=protected)
        function figureGroupKeyName=figureGetGroupKeyFunc(self,sTime,lsGoodDirVec)
            figureGroupKeyName=sprintf(...
                ['Ellipsoidal tube characteristics for ',...
                'lsGoodDirVec=%s,sTime=%f'],...
                self.goodDirProp2Str(lsGoodDirVec,sTime));
        end
        function figureSetPropFunc(~,hFigure,figureName,~)
            set(hFigure,'NumberTitle','off','WindowStyle','docked',...
                'RendererMode','manual','Renderer','OpenGL',...
                'Name',figureName);
        end
        function axesName=axesGetKeyDiamFunc(self,sTime,lsGoodDirVec)
            axesName=sprintf('Diameters for\n %s',...
                self.goodDirProp2Str(lsGoodDirVec,sTime));
        end
        function hVec=axesSetPropDiamFunc(self,hAxes,axesName)
            hVec=axesSetPropBasicFunc(self,hAxes,axesName,'diameter');
        end
        %
        function axesName=axesGetKeyTraceFunc(self,sTime,lsGoodDirVec)
            axesName=sprintf('Ellipsoid matrix traces for\n %s',...
                self.goodDirProp2Str(lsGoodDirVec,sTime));
        end
        function hVec=axesSetPropTraceFunc(self,hAxes,axesName)
            hVec=axesSetPropBasicFunc(self,hAxes,axesName,'trace');
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
        function hVec=plotTubeTraceFunc(~,hAxes,...
                approxType,timeVec,QArray,MArray)
            import gras.ellapx.enums.EApproxType;
            import modgen.common.throwerror;
            if approxType==EApproxType.Internal
                tubeArgList={'g-.'};
            elseif approxType==EApproxType.External
                tubeArgList={'b-.'};
            else
                throwerror('wrongInput',...
                    'Approximation type %s is not supported');
            end
            %
            hQVec=plotTrace(QArray,'tube',tubeArgList{:});
            if approxType==EApproxType.Internal
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
        function hVec=plotTubeDiamFunc(~,hAxes,...
                approxType,timeVec,QArray,MArray)
            import gras.ellapx.enums.EApproxType;
            import modgen.common.throwerror;
            if approxType==EApproxType.Internal
                tubeArgList={'g-.'};
            elseif approxType==EApproxType.External
                tubeArgList={'b-.'};
            else
                throwerror('wrongInput',...
                    'Approximation type %s is not supported');
            end
            %
            hQVec=plotEig(QArray,'tube',tubeArgList{:});
            if approxType==EApproxType.Internal
                hMVec=plotEig(MArray,'reg','r-');
            else
                hMVec=[];
            end
            
            hVec=[hQVec,hMVec];
            %
            axis(hAxes,'tight');
            axis(hAxes,'normal');
            hold(hAxes,'on');
            function hVec=plotEig(InpArray,namePrefix,lineSpec,varargin)
                import modgen.common.throwerror;
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
    end
    methods
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
            % $Author: Peter Gagarinov  <pgagarinov@gmail.com> $        $Date: 2011-12-19 $
            % $Copyright: Moscow State University,
            %            Faculty of Computational Mathematics and Computer Science,
            %            System Analysis Department 2011 $
            %
            import modgen.logging.log4j.Log4jConfigurator;
            if self.getNTuples()>0
                if nargin<2
                    plObj=smartdb.disp.RelationDataPlotter;
                end
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
    end
    methods (Static)
        function ellTubeRel=fromQArrays(QArrayList,aMat,varargin)
            % FROMQARRAYS  - creates a relation object using an array of ellipsoids,
            %                described by the array of ellipsoid matrices and
            %                array of ellipsoid centers.This method used default
            %                scale factor.
            %
            % Input:
            %   regular:
            %     QArrayList: double[nDim1, nDim2, ..., nDimN] - array of ellipsoid
            %         matrices
            %     aMat: double[nDim1, nDim2, ..., nDimN] - array of ellipsoid centers
            %
            % Optional:
            %    MArrayList:cell[1, nElem] - array of regularization ellipsoid matrices
            %    timeVec:cell[1, m] - time vector
            %    ltGoodDirArray:cell[1, nElem] - good direction at time s
            %    sTime:double[1, 1] - time s
            %    approxType:gras.ellapx.enums.EApproxType - type of approximation
            %                 (external, internal, not defined)
            %    approxSchemaName:cell[1,] - name of the schema
            %    approxSchemaDescr:cell[1,] - description of the schema
            %    calcPrecision:double[1, 1] - calculation precision
            %
            % Output:
            %    ellTubeRel: smartdb.relation.StaticRelation[1, 1] - constructed relation
            %        object
            import gras.ellapx.smartdb.rels.EllTube;
            import gras.ellapx.smartdb.rels.EllTubeBasic;
            %
            MArrayList=cellfun(@(x)zeros(size(x)),QArrayList,...
                'UniformOutput',false);
            STubeData=EllTubeBasic.fromQArraysInternal(QArrayList,aMat,...
                MArrayList,varargin{:},...
                EllTube.DEFAULT_SCALE_FACTOR(ones(size(MArrayList))));
            ellTubeRel=EllTube(STubeData);
        end
        function ellTubeRel=fromQMArrays(QArrayList,aMat,MArrayList,...
                varargin)
            % FROMQMARRAYS  - creates a relation object using an array of ellipsoids,
            %                 described by the array of ellipsoid matrices and
            %                 array of ellipsoid centers. Also this method uses
            %                 regularizer in the form of a matrix function. This method
            %                 used default scale factor.
            %
            % Input:
            %   regular:
            %   QArrayList: double[nDim1, nDim2, ..., nDimN] - array of ellipsoid
            %         matrices
            %   aMat: double[nDim1, nDim2, ..., nDimN] - array of ellipsoid centers
            %   MArrayList: double[nDim1, nDim2, ..., nDimN] - ellipsoid  matrices of
            %         regularization
            %
            %  optional:
            %    timeVec:cell[1, m] - time vector
            %    ltGoodDirArray:cell[1, nElem] - good direction at time s
            %    sTime:double[1, 1] - time s
            %    approxType:gras.ellapx.enums.EApproxType - type of approximation
            %                 (external, internal, not defined)
            %    approxSchemaName:cell[1,] - name of the schema
            %    approxSchemaDescr:cell[1,] - description of the schema
            %    calcPrecision:double[1, 1] - calculation precision
            %
            % Output:
            %    ellTubeRel: smartdb.relation.StaticRelation[1, 1] - constructed relation
            %          object
            import gras.ellapx.smartdb.rels.EllTube;
            import gras.ellapx.smartdb.rels.EllTubeBasic;
            %
            STubeData=EllTubeBasic.fromQArraysInternal(QArrayList,aMat,...
                MArrayList,varargin{:},...
                EllTube.DEFAULT_SCALE_FACTOR(ones(size(MArrayList))));
            ellTubeRel=EllTube(STubeData);
        end
        function ellTubeRel=fromQMScaledArrays(QArrayList,aMat,MArrayList,...
                varargin)
            % FROMQMSCALEDARRAYS  - creates a relation object using an array of ellipsoids,
            %                       described by the array of ellipsoid matrices and
            %                       array of ellipsoid centers. Also this method uses
            %                       regularizer in the form of a matrix function.
            %
            %
            % Input:
            %   regular:
            %     QArrayList: double[nDim1, nDim2, ..., nDimN] - array of ellipsoid
            %         matrices
            %     aMat: double[nDim1, nDim2, ..., nDimN] - array of ellipsoid centers
            %     MArrayList: double[nDim1, nDim2, ..., nDimN] - ellipsoid matrices
            %               of regularization
            %     scaleFactor:double[1, 1] - tube scale factor
            %
            %  optional:
            %    timeVec:cell[1, m] - time vector
            %    ltGoodDirArray:cell[1, nElem] - good direction at time s
            %    sTime:double[1, 1] - time s
            %    approxType:gras.ellapx.enums.EApproxType - type of approximation
            %                 (external, internal, not defined)
            %    approxSchemaName:cell[1,] - name of the schema
            %    approxSchemaDescr:cell[1,] - description of the schema
            %    calcPrecision:double[1, 1] - calculation precision
            %
            % Output:
            %    ellTubeRel: smartdb.relation.StaticRelation[1, 1] - constructed relation
            %          object
            import gras.ellapx.smartdb.rels.EllTube;
            import gras.ellapx.smartdb.rels.EllTubeBasic;
            %
            STubeData=EllTubeBasic.fromQArraysInternal(QArrayList,aMat,...
                MArrayList,varargin{:});
            ellTubeRel=EllTube(STubeData);
        end
        function ellTubeRel = fromEllMArray(qEllArray, ellMArr, varargin)
            % FROMELLMARRAY  - creates a relation object using an array of ellipsoids.
            %                  This method uses regularizer in the form of a matrix
            %                  function.
            %
            % Input:
            %   regular:
            %     qEllArray: ellipsoid[nDim1, nDim2, ..., nDimN] - array of ellipsoids
            %     ellMArr: double[nDim1, nDim2, ..., nDimN] - regularization ellipsoid
            %         matrices
            %
            %   optional:
            %    timeVec:cell[1, m] - time vector
            %    ltGoodDirArray:cell[1, nElem] - good direction at time s
            %    sTime:double[1, 1] - time s
            %    approxType:gras.ellapx.enums.EApproxType - type of approximation
            %                 (external, internal, not defined)
            %    approxSchemaName:cell[1,] - name of the schema
            %    approxSchemaDescr:cell[1,] - description of the schema
            %    calcPrecision:double[1, 1] - calculation precision
            %
            % Output:
            %    ellTubeRel: smartdb.relation.StaticRelation[1, 1] - constructed relation
            %          object
            import gras.ellapx.smartdb.rels.EllTube;
            import gras.ellapx.smartdb.rels.EllTubeBasic;
            nPoints = length(qEllArray);
            nDims = size(parameters(qEllArray(1)), 1);
            qArray = zeros(nDims, nDims, nPoints);
            aMat = zeros(nDims, nPoints);
            arrayfun(@(iPoint)fCalcAMatAndQArray(iPoint), 1:nPoints);
            %
            STubeData=EllTubeBasic.fromQArraysInternal({qArray}, aMat,...
                {ellMArr},varargin{:},...
                EllTube.DEFAULT_SCALE_FACTOR(1));
            ellTubeRel=EllTube(STubeData);
            %
            function fCalcAMatAndQArray(iPoint)
                [aMat(:, iPoint), qArray(:,:,iPoint)] =...
                    parameters(qEllArray(iPoint));
            end
        end
        function ellTubeRel = fromEllArray(qEllArray, varargin)
            % FROMELLARRAY  - creates a relation object using an array of ellipsoids
            %
            % Input:
            %   regular:
            %     qEllArray: ellipsoid[nDim1, nDim2, ..., nDimN] - array of ellipsoids
            %
            %   optional:
            %    timeVec:cell[1, m] - time vector
            %    ltGoodDirArray:cell[1, nElem] - good direction at time s
            %    sTime:double[1, 1] - time s
            %    approxType:gras.ellapx.enums.EApproxType - type of approximation
            %                 (external, internal, not defined)
            %    approxSchemaName:cell[1,] - name of the schema
            %    approxSchemaDescr:cell[1,] - description of the schema
            %    calcPrecision:double[1, 1] - calculation precision
            %
            % Output:
            %    ellTubeRel: smartdb.relation.StaticRelation[1, 1] - constructed relation
            %        object
            import gras.ellapx.smartdb.rels.EllTube;
            import gras.ellapx.smartdb.rels.EllTubeBasic;
            nPoints = length(qEllArray);
            nDims = size(parameters(qEllArray(1)), 1);
            mArray = zeros([nDims, nDims, nPoints]);
            ellTubeRel = EllTube.fromEllMArray(...
                qEllArray, mArray, varargin{:});
        end
    end
    methods
        function catEllTubeRel = cat(self, newEllTubeRel,...
                varargin)
            % CAT  - concatenates data from relation objects.
            %
            % Input:
            %   regular:
            %       self.
            %       newEllTubeRel: smartdb.relation.StaticRelation[1, 1]/
            %           smartdb.relation.DynamicRelation[1, 1] - relation object
            %   properties:
            %       isReplacedByNew: logical[1,1] - if true, sTime and
            %           values of properties corresponding to sTime are taken
            %           from newEllTubeRel. Common times in self and
            %           newEllTubeRel are allowed, however the values for
            %           those times are taken either from self or from
            %           newEllTubeRel depending on value of isReplacedByNew
            %           property
            %
            %       isCommonValuesChecked: logical[1,1] - if true, values
            %           at common times (if such are found) are checked for
            %           strong equality (with zero precision). If not equal
            %           - an exception is thrown. True by default.
            %
            %       commonTimeAbsTol: double[1,1] - absolute tolerance used
            %           for comparing values at common times, =0 by default
            %
            %       commonTimeRelTol: double[1,1] - absolute tolerance used
            %           for comparing values at common times, =0 by default
            %
            % Output:
            %   catEllTubeRel:smartdb.relation.StaticRelation[1, 1]/
            %       smartdb.relation.DynamicRelation[1, 1] - relation object
            %       resulting from CAT operation
            %
            import gras.ellapx.smartdb.F;
            import modgen.common.parseparext;
            import modgen.common.throwerror;
            [~,~,isReplacedByNew,isCommonValuesChecked,...
                commonTimeAbsTol,commonTimeRelTol]=...
                parseparext(varargin,...
                {'isReplacedByNew','isCommonValuesChecked',...
                'commonTimeAbsTol','commonTimeRelTol';...
                false,true,0,0;...
                'islogical(x)&&isscalar(x)',...
                'islogical(x)&&isscalar(x)',...
                'isfloat(x)&&isscalar(x)&&(x>=0)',...
                'isfloat(x)&&isscalar(x)&&(x>=0)'},...
                0);
            %
            SDataFirst = self.getData();
            SDataSecond = newEllTubeRel.getData();
            %
            isNotOkVec=cellfun(@(x,y)x(end)>y(1),...
                SDataFirst.timeVec,SDataSecond.timeVec);
            if any(isNotOkVec)
                throwerror('wrongInput:commonTimeVecEntries',...
                    ['cannot concatenate relations ',...
                    'with overlapping time limits']);
            end
            %
            isDelCommonTimeList=cellfun(@(x,y)x(end)==y(1),...
                SDataFirst.timeVec,SDataSecond.timeVec,'UniformOutput',false);
            %
            SCatFunResult = SDataFirst;
            fieldsNotToCatVec=self.getNoCatOrCutFieldsList();
            fieldsToCatVec =...
                setdiff(fieldnames(SDataFirst), fieldsNotToCatVec);
            %
            fCut=@(varargin)catArr(...
                varargin{:},isReplacedByNew);
            %
            cellfun(@(x)catStructField(x,fCut),fieldsToCatVec);
            %
            if isReplacedByNew
                nRepFields=length(fieldsNotToCatVec);
                for iField=1:nRepFields
                    fieldName=fieldsNotToCatVec{iField};
                    SCatFunResult.(fieldName)=SDataSecond.(fieldName);
                end
                sTimeVec=SDataSecond.sTime;
            else
                sTimeVec=SDataFirst.sTime;
            end
            SCatFunResult.indSTime=...
                cellfun(@(x,y)find(x==y,1,'first'),...
                SCatFunResult.timeVec,num2cell(sTimeVec));
            %
            catEllTubeRel = self.createInstance(SCatFunResult);
            %
            function catStructField(fieldName,fCut)
                SCatFunResult.(fieldName) =...
                    cellfun(@(varargin)fCut(varargin{:},fieldName),...
                    SDataFirst.(fieldName),...
                    SDataSecond.(fieldName),...
                    isDelCommonTimeList,...
                    'UniformOutput', false);
            end
            %
            function resArr = catArr(leftArr,rightArr,isCommon,...
                    fieldName,isRightTaken)
                import modgen.common.throwerror;
                nDims = ndims(leftArr);
                if nDims<2||nDims>3
                    throwerror('wrongInput',...
                        sprintf(...
                        'dimensionality %d is not supported, field %s',...
                        nDims,fieldName));
                end
                if isCommon
                    if isCommonValuesChecked
                        if nDims==2
                            leftCutArr=leftArr(:,end);
                            rightCutArr=rightArr(:,1);
                        else
                            leftCutArr=leftArr(:,:,end);
                            rightCutArr=rightArr(:,:,1);
                        end
                        if isnumeric(leftCutArr)
                            [isEq,~,~,~,~,suffixStr]=...
                                modgen.common.absrelcompare(leftCutArr(:),...
                                rightCutArr(:),commonTimeAbsTol,...
                                commonTimeRelTol,@norm);
                        else
                            isEq=isequal(leftCutArr,rightCutArr);
                        end
                        if ~isEq
                            throwerror('wrongInput:commonValuesDiff',...
                                ['field %s values at common times ',...
                                'are different ',suffixStr],...
                                fieldName);
                        end
                    end
                    if nDims==2
                        if isRightTaken
                            resArr=cat(2,leftArr(:,1:end-1),rightArr);
                        else
                            resArr=cat(2,leftArr,rightArr(:,2:end));
                        end
                    else
                        if isRightTaken
                            resArr=cat(3,leftArr(:,:,1:end-1),rightArr);
                        else
                            resArr=cat(3,leftArr,rightArr(:,:,2:end));
                        end
                    end
                else
                    resArr=cat(nDims,leftArr,rightArr);
                end
            end
        end
        function scale(self,fCalcFactor,fieldNameList)
            % SCALE - scales relation object
            %
            %  Input:
            %   regular:
            %      self.
            %      fCalcFactor - function which calculates factor for
            %                     fields in fieldNameList
            %        Input:
            %          regular:
            %            fieldNameList: char/cell[1,] of char - a list of fields
            %                   for which factor will be calculated
            %         Output:
            %             factor:double[1, 1] - calculated factor
            %
            %       fieldNameList:cell[1,nElem]/char[1,] - names of the fields
            %
            %  Output:
            %       none
            %
            % Example:
            %   nPoints=5;
            %   calcPrecision=0.001;
            %   approxSchemaDescr=char.empty(1,0);
            %   approxSchemaName=char.empty(1,0);
            %   nDims=3;
            %   nTubes=1;
            %   lsGoodDirVec=[1;0;1];
            %   aMat=zeros(nDims,nPoints);
            %   timeVec=1:nPoints;
            %   sTime=nPoints;
            %   approxType=gras.ellapx.enums.EApproxType.Internal;
            %   qArrayList=repmat({repmat(diag([1 2 3]),[1,1,nPoints])},1,nTubes);
            %   ltGoodDirArray=repmat(lsGoodDirVec,[1,nTubes,nPoints]);
            %   fromMatEllTube=...
            %         gras.ellapx.smartdb.rels.EllTube.fromQArrays(qArrayList,...
            %         aMat, timeVec,ltGoodDirArray, sTime, approxType,...
            %         approxSchemaName, approxSchemaDescr, calcPrecision);
            %   fromMatEllTube.scale(@(varargin)2,{});
            import gras.ellapx.smartdb.rels.EllTubeBasic;
            scaleFactorVec=self.applyTupleGetFunc(fCalcFactor,...
                fieldNameList);
            %
            self.setDataInternal(...
                EllTubeBasic.scaleTubeData(self.getData(),scaleFactorVec));
        end
        function self=EllTube(varargin)
            self=self@gras.ellapx.smartdb.rels.ATypifiedAdjustedRel(...
                varargin{:});
        end
        function [ellTubeProjRel,indProj2OrigVec]=project(self,varargin)
            import gras.ellapx.smartdb.rels.EllTubeProj;
            if self.getNTuples()>0
                [rel,indProj2OrigVec]=self.projectInternal(varargin{:});
                ellTubeProjRel=EllTubeProj(rel);
            else
                ellTubeProjRel=EllTubeProj();
                indProj2OrigVec=zeros(0,1);
            end
        end
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
    end
end