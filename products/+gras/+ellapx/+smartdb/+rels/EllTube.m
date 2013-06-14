classdef EllTube<gras.ellapx.smartdb.rels.TypifiedByFieldCodeRel&...
        gras.ellapx.smartdb.rels.EllTubeBasic
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
        function isNeededIndVec = getLogicalInd(indVec, timeVec)
            import modgen.common.throwerror
            %
            nPoints = numel(timeVec);
            if isa(indVec, 'double')
                if min(indVec) < 1 || max(indVec) > nPoints
                    throwerror('wrongInput', 'Indexes are out of range.');
                end
                isNeededIndVec = false(size(timeVec));
                isNeededIndVec(indVec) = true;
            elseif islogical(indVec)
                if numel(indVec) ~= nPoints
                    throwerror('wrongInput', 'Indexes are out of range.');
                end
                isNeededIndVec = indVec;
            else
                throwerror('wrongInput',...
                    'indVec should be double or logical');
            end
        end
    end
    methods
        function catEllTubeRel = cat(self, newEllTubeRel, indVec)
            % CAT  - concatenates data from relation objects.
            %
            % Input:
            %  regular:
            %    self.
            %    newEllTubeRel: smartdb.relation.StaticRelation[1, 1]/
            %      smartdb.relation.DynamicRelation[1, 1] - relation object
            %
            % Output:
            %    catEllTubeRel:smartdb.relation.StaticRelation[1, 1]/
            %      smartdb.relation.DynamicRelation[1, 1] - relation object resulting 
            %      from CAT operation
            import gras.ellapx.smartdb.F;
            SDataFirst = self.getData();
            SDataSecond = newEllTubeRel.getData();
            SCatFunResult = SDataFirst;
            timeVec = SDataSecond.timeVec{1};
            if nargin == 2
                indVec = true(size(timeVec));
            end
            isNeededIndVec = self.getLogicalInd(indVec, timeVec);
            fieldsNotToCatVec =...
                F.getNameList(self.getNoCatOrCutFieldsList());
            fieldsToCatVec =...
                setdiff(fieldnames(SDataFirst), fieldsNotToCatVec);
            cellfun(@(field) catStructField(field, isNeededIndVec),...
                fieldsToCatVec);
            catEllTubeRel = self.createInstance(SCatFunResult);
            %
            function catStructField(fieldName, isNeededIndVec)
                SCatFunResult.(fieldName) =...
                    cellfun(@(firstStructFieldVal, secondStructFieldVal)...
                    cat(ndims(firstStructFieldVal), firstStructFieldVal,...
                    self.getCutObj(secondStructFieldVal,...
                    isNeededIndVec)), SDataFirst.(fieldName),...
                    SDataSecond.(fieldName), 'UniformOutput', false);
            end
        end
        function cutEllTubeRel = cut(self, cutTimeVec)
            % CUT - extracts the piece of the relation object from given start time to
            %       given end time.
            % Input:
            %  regular:
            %     self.
            %     cutTimeVec: double[1, 2]/ double[1, 1] - time interval to cut
            % 
            % Output:
            % cutEllTubeRel: smartdb.relation.StaticRelation[1, 1]/
            %      smartdb.relation.DynamicRelation[1, 1] - relation object resulting 
            %      from CUT operation
            import gras.ellapx.smartdb.F;
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
                [unTimeVec, unVec, notUnVec] = unique(timeVec);
                isSysNewTimeIndVec = false(size(timeVec));
                isSysNewTimeIndVec(unVec) = true;
                isSysNewTimeIndVec = isSysNewTimeIndVec &...
                    ~(isSysTimeLowerVec | isSysTimeGreaterVec);
            end
            %
            cutEllTubeRel =...
                self.thinOutTuples(isSysNewTimeIndVec);
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
            self=self@gras.ellapx.smartdb.rels.TypifiedByFieldCodeRel(...
                varargin{:});
        end
        function [ellTubeProjRel,indProj2OrigVec]=project(self,varargin)
            import gras.ellapx.smartdb.rels.EllTubeProj;
            if self.getNTuples()>0
                [rel,indProj2OrigVec]=project@...
                    gras.ellapx.smartdb.rels.EllTubeBasic(...
                    self,varargin{:});
                ellTubeProjRel=EllTubeProj(rel);
            else
                ellTubeProjRel=EllTubeProj();
            end
        end
    end
end