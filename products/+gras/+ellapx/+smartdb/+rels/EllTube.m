classdef EllTube<gras.ellapx.smartdb.rels.TypifiedByFieldCodeRel&...
        gras.ellapx.smartdb.rels.EllTubeBasic
    %TestRelation Summary of this class goes here
    %   Detailed explanation goes here
    methods(Access=protected)
        function changeDataPostHook(self)
            self.checkDataConsistency();
        end
    end
    properties (GetAccess=private,Constant)
        DEFAULT_SCALE_FACTOR=1;
        FIELDS_NOT_TO_CAT_OR_CUT={'APPROX_SCHEMA_DESCR';'DIM';...
            'APPROX_SCHEMA_NAME';'APPROX_TYPE';'CALC_PRECISION';...
            'IND_S_TIME';'LS_GOOD_DIR_NORM';'LS_GOOD_DIR_VEC';'S_TIME';...
            'SCALE_FACTOR';'XS_TOUCH_OP_VEC';'XS_TOUCH_VEC'};
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
                    eMat(:,iTime)=sqrt(eSquaredVec);
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
            % PLOT displays ellipsoidal tubes using the specified
            % RelationDataPlotter
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
            import gras.ellapx.smartdb.rels.EllTube;
            import gras.ellapx.smartdb.rels.EllTubeBasic;
            %
            STubeData=EllTubeBasic.fromQArraysInternal(QArrayList,aMat,...
                MArrayList,varargin{:});
            ellTubeRel=EllTube(STubeData);
        end
    end
    methods
        function thinnedEllTubeRel =...
                thinOutTuples(self, indVec)
            import gras.ellapx.smartdb.F;
            import modgen.common.throwerror;
            SData = self.getData();
            SCutFunResult = SData;
            timeVec = SData.timeVec{1};
            nPoints = numel(timeVec);
            if min(indVec) < 1 || max(indVec) > nPoints
                throwerror('Indexes are out of range.');
            end
            isNeededIndVec = false(size(timeVec));
            isNeededIndVec(indVec) = true;
            %
            fieldsNotToCatVec =...
                F.getNameList(self.FIELDS_NOT_TO_CAT_OR_CUT);
            fieldsToCutVec =...
                setdiff(fieldnames(SData), fieldsNotToCatVec);
            cellfun(@(field) cutStructField(field), fieldsToCutVec);
            SCutFunResult.sTime(:) =...
                timeVec(find(isNeededIndVec == true, 1));
            SCutFunResult.indSTime(:) = 1;
            SCutFunResult.lsGoodDirVec = cellfun(@(field) field(:, 1),...
                SCutFunResult.ltGoodDirMat, 'UniformOutput', false);
            SCutFunResult.lsGoodDirNorm = cellfun(@(field) field(1, 1),...
                SCutFunResult.ltGoodDirNormVec);
            SCutFunResult.xsTouchVec = cellfun(@(field) field(:, 1),...
                SCutFunResult.xTouchCurveMat, 'UniformOutput', false);
            SCutFunResult.xsTouchOpVec = cellfun(@(field) field(:, 1),...
                SCutFunResult.xTouchOpCurveMat, 'UniformOutput', false);
            thinnedEllTubeRel = self.createInstance(SCutFunResult);
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
                SCutFunResult.(fieldName) = cellfun(@(StructFieldVal)...
                    getCutObj(StructFieldVal, isNeededIndVec),...
                    SData.(fieldName), 'UniformOutput', false);
            end
        end
        function catEllTubeRel = cat(self, newEllTubeRel)
            import gras.ellapx.smartdb.F;
            SDataFirst = self.getData();
            SDataSecond = newEllTubeRel.getData();
            SCatFunResult = SDataFirst;
            fieldsNotToCatVec =...
                F.getNameList(self.FIELDS_NOT_TO_CAT_OR_CUT);
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
        function cutEllTubeRel = cut(self, cutTimeVec)
            import gras.ellapx.smartdb.F;
            import modgen.common.throwerror;
            %
            if numel(cutTimeVec) == 1
                cutTimeVec = [cutTimeVec(1) cutTimeVec(1)];
            end
            if numel(cutTimeVec) ~= 2
                throwerror(['Cut:input vector should ',...
                    'contain 1 or 2 elements']);
            end
            cutStartTime = cutTimeVec(1);
            cutEndTime = cutTimeVec(2);
            if cutStartTime > cutEndTime
                throwerror('Cut:s0 must be LEQ than s1');
            end
            timeVec = self.timeVec{1};
            sysStartTime = timeVec(1);
            sysEndTime = timeVec(end);
            if cutStartTime < sysStartTime ||...
                    cutStartTime > sysEndTime ||...
                    cutEndTime < sysStartTime ||...
                    cutEndTime > sysEndTime
                throwerror('Cut:wrong input format');
            end
            if cutTimeVec(1) == cutTimeVec(2)
                indClosestVec = find(timeVec <= cutStartTime, 1, 'last');
                isSysNewTimeIndVec = false(size(timeVec));
                isSysNewTimeIndVec(indClosestVec) = true;
            else
                isSysTimeLowerVec = timeVec < cutStartTime;
                isSysTimeGreaterVec = timeVec > cutEndTime;    
                isSysNewTimeIndVec =...
                    ~(isSysTimeLowerVec | isSysTimeGreaterVec);
            end
            %
            cutEllTubeRel =...
                self.thinOutTuples(find(isSysNewTimeIndVec));
        end
        function scale(self,fCalcFactor,fieldNameList)
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