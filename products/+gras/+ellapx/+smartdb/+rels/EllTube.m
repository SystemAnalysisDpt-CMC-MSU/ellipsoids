classdef EllTube<gras.ellapx.smartdb.rels.ATypifiedAdjustedRel&...
        gras.ellapx.smartdb.rels.EllTubeBasic&...
        gras.ellapx.smartdb.rels.AEllTubeProjectable
    % EllTube - ellipsoidal tube collection
    %
    % Public properties:
    %   QArray: cell[nTubes,1] of double[nDims,nDims,nTimePoints] - list of
    %       ellipsoidal tube configuration matrix arrays where nDims is a tube
    %       dimensionality and nTimePoints is a number of time points.
    %       Each tube can have its own values of nDims and nTimePoints
    %   aMat: cell[nTubes,1] of double[nDims,nTimePoints] - list of ellipsoidal
    %       tube center arrays
    %   scaleFactor: double[nTubes,1] - tube scale factor array. Each tube
    %       can be slightly stretched or squeezed to avoid an overlapping of
    %       patch object edges on 3d plots. For that reason external tubes
    %       often have a scale factor>1 while internal tubes - scale
    %       factor<1
    %   MArray: -same size as QArray, contain regularization matrices M(t)
    %       arrays which are zero for systems without disturbance and for
    %       systems with disturbance that didn't require regularization.
    %       Matrix M(t) modifies a configuration matrix P(t) for control
    %       constrains producing a regularized control constraint
    %       ellipsoid configuration matrix P*(t)=P(t)+M(t).
    %   dim: double[nTubes,1] - vector of ellipsoid tube dimensionalities
    %   sTime: double[nTubes,1] - vector of t_s values at which initial
    %       directions for good direction curve l(t) are specified. Usually
    %       t_s=0 or T where T is the end of the time internal.
    %   approxSchemaName: cell[nTubes,1] of char[1,] - list of ellipsoidal
    %       approximation schema names
    %   approxSchemaDescr: cell[nTubes,1] of char[1,] - list of ellipsoidal
    %       approximation schema descriptions
    %   approxType: gras.ellapx.enums.EApproxType[nTubes,1] - vector of
    %       ellipsoidal approximation types, can be
    %       "External", "Internal" and "NotDefined"
    %   timeVec: cell[nTubes,1] of double[1,nTimePoints] - list of time
    %       vectors for each tube
    %   absTol: double[nTubes,1] - vector of absolute tolerances used for
    %       calculating the corresponding ellipsoidal tube
    %   relTol: double[nTubes,1] - vector of relative tolerances used for
    %       calculating the corresponding ellipsoidal tubes
    %   indSTime: double[nTubes,1] - vector of positions of sTime
    %       within timeVec for each tube
    %   ltGoodDirMat: cell[nTubes,1] of double[nDims,nTimePoints] - list of
    %       l(t) arrays for each tube
    %   lsGoodDirVec: cell[nTubes,1] of double[nDims,1] - list of l(t_s)
    %       for each tube
    %   ltGoodDirNormVec: cell[nTubes,1] of double[1,nTimePoints] - list of
    %       ||l(t)|| vectors for each tube
    %   lsGoodDirNorm: double[nTubes,1] - vector of ||l(t_s)|| values
    %   xTouchCurveMat: cell[nTubes,1] of double[nDims,nTimePoints] - list
    %       of vectors of maximizers for \rho(l(t)|E(t)) i.e. vectors x*(t)
    %       such that maximize scalar product (x,l(t)) where x belong
    %       ellipsoidal tube E(t)
    %   xTouchOpCurveMat: - same as xTouchCurveMat but for -l(t) i.e.
    %       direction opposite to l(t)
    %   xsTouchVec: cell[nTubes,1] of double[nDims,1] - same as
    %       xTouchCurveMat but just for one time point t_s
    %   xsTouchOpVec: - same as xsTouchVec but for -l(t) i.e. direction
    %       opposite to l(t)
    %   isLsTouch: logical[nTubes,1] - indicates whether ellipsoidal tube
    %       cut E[t_s] touches a reachability tube along l(t_s)
    %   isLtTouchVec: cell[nTubes,1] of double[1,nTimePoints] - for each
    %       tube indicates whether a touch takes place along l(t)
    %       for all time points t from timeVec
    %
    % $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-2015 $
    % $Copyright: Moscow State University,
    %            Faculty of Computational Mathematics and Computer Science,
    %            System Analysis Department 2015 $
    methods(Access=protected)
        function changeDataPostHook(self)
            self.checkDataConsistency();
        end
    end
    methods (Access=protected,Static,Hidden)
        function outObj=loadobj(inpObj)
            import gras.ellapx.smartdb.rels.ATypifiedAdjustedRel;
            outObj=ATypifiedAdjustedRel.loadObjViaConstructor(...
                mfilename('class'),inpObj);
        end
    end
    %
    methods (Access=protected)
        function figureGroupKeyName=figureGetGroupKeyFunc(self,sTime,lsGoodDirVec)
            figureGroupKeyName=sprintf(...
                ['Ellipsoidal tube characteristics for ',...
                'lsGoodDirVec=%s,sTime=%f'],...
                self.goodDirProp2Str(lsGoodDirVec,sTime));
        end
        function figureSetPropFunc(~,hFigure,figureName,~)
            if usejava('swing')
                winStyleArgList={'WindowStyle','docked'};
            else
                winStyleArgList={};
            end
            %
            set(hFigure,'NumberTitle','off',winStyleArgList{:},...
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
            hTitle=get(hAxes,'Title');
            set(hTitle,'String',axesName);
            xLabel='time';
            %
            hXLabel=get(hAxes,'XLabel');
            set(hXLabel,'String',xLabel,'Interpreter','tex');
            hYLabel=get(hAxes,'YLabel');
            set(hYLabel,'String',yLabel,'Interpreter','tex');
            %
            set(hAxes,'xtickmode','auto',...
                'ytickmode','auto','xgrid','on','ygrid','on');
            hVec=[hXLabel,hYLabel,hTitle];
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
            % FROMQARRAYS  - creates an ellipsoidal tubes object
            %   using an array of ellipsoid configuration matrices and
            %   ellipsoid centers along with other parameters
            %
            % Input:
            %   same as in fromQMArrays but without MArrayList input
            %   which is not specified and assumed to contain zero M(t)
            %
            % Output:
            %   ellTubeRel: gras.ellapx.smartdb.rels.EllTube[1,1]
            %       - constructed ellipsoidal tubes object
            %
            import gras.ellapx.smartdb.rels.EllTube;
            %
            MArrayList=cellfun(@(x)zeros(size(x)),QArrayList,...
                'UniformOutput',false);
            STubeData=EllTube.fromQArraysInternal(QArrayList,aMat,...
                MArrayList,varargin{:});
            ellTubeRel=EllTube(STubeData);
        end
        function ellTubeRel=fromQMArrays(QArrayList,aMat,MArrayList,...
                varargin)
            % FROMQMARRAYS  - creates an ellipsoidal tubes object
            %   using an array of ellipsoid configuration matrices,
            %   ellipsoid centers and an array of ellipsoidal tube
            %   regularization matrices along with other parameters
            %
            % Input:
            %   regular:
            %       QArrayList: cell[nTubes,1]/cell[1,nTubes] of
            %           double[nDims,nDims,nTimePoints] - list of arrays of
            %               ellipsoidal tube configuration matrices
            %               where nDims is a dimension of ellipsoid
            %               and nTimePoints is a number of time points
            %       aMat: double[nDims,nTimePoints]
            %           OR
            %           cell[nTubes,1]/cell[1,nTubes] of
            %           double[nDims,nTimePoints] - an array of ellipsoidal
            %               centers
            %               OR
            %               a list of arrays of ellipsoidal centers
            %       MArrayList: cell[0,0]/cell[nTubes,1]/cell[1,nTubes] of
            %           double[nDims,nDims,nTimePoints] - list of arrays of
            %               ellipsoidal tube regularization matrices
            %
            %              Note: if empty cell is specified then MArrayList
            %              is assumed to contain zero M(t) matrices i.e.
            %              specifying an empty cell is the same as
            %              specifying a cell vector of zero arrays
            %
            %       timeVec: double[1,nTimePoints]
            %           OR
            %           cell[nTubes,1]/cell[1,nTubes] of
            %           double[1,nTimePoints] - a time point vector or
            %               a list of time point vectors
            %       ltGoodDirArray: double[nDims,nTubes,nTimePoints]
            %           OR
            %           double[nDims,nTimePoints]
            %           OR
            %           cell[nTubes,1]/cell[1,nTubes] of
            %           double[nDims,nTimePoints] - an array of l(t) for
            %               each tube
            %               OR an array of l(t) for all tubes
            %               OR a list of l(t) arrays for each tube
            %       sTime: double[1,1]
            %           OR
            %           double[nTubes,1] - a value of s time for all tubes
            %               OR
            %               an array of s time values for each tube
            %       approxType: gras.ellapx.enums.EApproxType[1,1]
            %           /[nTubes,1]/[1,nTubes]  - type/types of approximation
            %                  (external, internal, not defined)
            %       approxSchemaName: cell[nTubes,1]/cell[1,nTubes] of char[1,]
            %           OR
            %           char[1,] - names/name of approximation schema
            %       approxSchemaDescr: cell[nTubes,1]/cell[1,nTubes] of
            %           char[1,]
            %           OR
            %           char[1,] - - descriptions/description of
            %               approximation schema
            %       absTol: double[1,1]/[nTubes,1]/[1,nTubes] - absolute
            %           tolerance/tolerances for each tube
            %       relTol: double[1,1]/[nTubes,1]/[1,nTubes] - relative
            %           tolerance/tolerances for each tube
            %       scaleFactorVec: double[1,1]/[nTubes,1]/[1,nTubes] -
            %           scale factor/factors for each tube
            %       isScaleFactorApplied: logical[1,1] - if true, scalor
            %           factor values from scaleFactorVec are considered
            %           already applied, otherwise scaling is performed
            %           automatically
            % Output:
            %   ellTubeRel: gras.ellapx.smartdb.rels.EllTube[1,1]
            %       - constructed ellipsoidal tubes object
            %
            import gras.ellapx.smartdb.rels.EllTube;
            %
            STubeData=EllTube.fromQArraysInternal(QArrayList,aMat,...
                MArrayList,varargin{:});
            ellTubeRel=EllTube(STubeData);
        end
        function ellTubeRel = fromEllMArray(ellVecList, varargin)
            % FROMELLMARRAYS  - creates an ellipsoidal tubes object
            %   using an array of ellipsoid representing ellipsoidal tube cuts,
            %   ellipsoid centers and an array of ellipsoidal tube
            %   regularization matrices along with other parameters
            %
            % Input:
            %   regular:
            %       ellArrList: ellipsoid[1,nTimePoints]
            %           OR
            %           cell[1,nTubes]/[nTubes,1] of
            %           ellipsoid[1,nTimePoints] -
            %               vector of ellipsoids
            %               OR
            %               a list of ellipsoid vectors representing cuts
            %               for each ellipsoidal tube
            %               where nDims is a dimension of ellipsoid
            %               and nTimePoints is a number of time points
            %
            %       +
            %
            %       same inputs as in fromQMArrays method starting with
            %           MArrayList
            % Output:
            %   ellTubeRel: gras.ellapx.smartdb.rels.EllTube[1,1]
            %       - constructed ellipsoidal tubes object
            %
            import gras.ellapx.smartdb.rels.EllTube;
            if ~iscell(ellVecList)
                ellVecList={ellVecList};
            end
            [bigQArrList,aMatList]=cellfun(@extractEllParams,ellVecList,...
                'UniformOutput',false);
            %
            STubeData=EllTube.fromQArraysInternal(bigQArrList, aMatList,...
                varargin{:});
            ellTubeRel=EllTube(STubeData);
            %
            function [bigQArr,aMat]=extractEllParams(ellVec)
                nPoints=numel(ellVec);
                nDims=ellVec(1).dimension();
                bigQArr = zeros(nDims,nDims,nPoints);
                aMat=zeros(nDims, nPoints);
                %
                for iPoint=1:nPoints
                    [aMat(:, iPoint),bigQArr(:,:,iPoint)]=...
                        ellVec(iPoint).parameters();
                end
            end
        end
        function ellTubeRel = fromEllArray(qEllArray, varargin)
            % FROMELLARRAY  - creates a relation object using an array of ellipsoids
            %
            % Input:
            %   same as in fromEllMArray but without MArrayList input which
            %   is not specified and assumed to contain zero M(t)
            %
            % Output:
            %   ellTubeRel: gras.ellapx.smartdb.rels.EllTube[1,1]
            %       - constructed ellipsoidal tubes object
            %
            import gras.ellapx.smartdb.rels.EllTube;
            ellTubeRel = EllTube.fromEllMArray(...
                qEllArray, {}, varargin{:});
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
            %   absTol=0.001;
            %   relTol = 0.001;
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
            %         approxSchemaName, approxSchemaDescr, absTol, relTol);
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