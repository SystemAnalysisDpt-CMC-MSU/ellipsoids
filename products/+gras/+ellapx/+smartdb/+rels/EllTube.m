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
        function catEllTubeRel = cat(self, newEllTubeRel)
            SDataFirst = self.getData();
            SDataSecond = newEllTubeRel.getData();
            nTuples = self.getNElems();
            %
            for iTuple = 1 : nTuples
                SDataFirst.timeVec{iTuple} =...
                    cat(2, SDataFirst.timeVec{iTuple},...
                    SDataSecond.timeVec{iTuple});
                SDataFirst.QArray{iTuple} =...
                    cat(3, SDataFirst.QArray{iTuple},...
                    SDataSecond.QArray{iTuple});
                SDataFirst.aMat{iTuple} =...
                    cat(2, SDataFirst.aMat{iTuple},...
                    SDataSecond.aMat{iTuple});
                SDataFirst.MArray{iTuple} =...
                    cat(3, SDataFirst.MArray{iTuple},...
                    SDataSecond.MArray{iTuple});
                SDataFirst.ltGoodDirMat{iTuple} =...
                    cat(2, SDataFirst.ltGoodDirMat{iTuple},...
                    SDataSecond.ltGoodDirMat{iTuple});
                SDataFirst.ltGoodDirNormVec{iTuple} =...
                    cat(2, SDataFirst.ltGoodDirNormVec{iTuple},...
                    SDataSecond.ltGoodDirNormVec{iTuple});
                SDataFirst.xTouchCurveMat{iTuple} =...
                    cat(2, SDataFirst.xTouchCurveMat{iTuple},...
                    SDataSecond.xTouchCurveMat{iTuple});
                SDataFirst.xTouchOpCurveMat{iTuple} =...
                    cat(2, SDataFirst.xTouchOpCurveMat{iTuple},...
                    SDataSecond.xTouchOpCurveMat{iTuple});
            end
            catEllTubeRel = ...
                gras.ellapx.smartdb.rels.EllTube.fromStructList(...
                'gras.ellapx.smartdb.rels.EllTube', {SDataFirst});
        end
        function cutEllTubeRel = cut(self, cutTimeVec)
            SData = self.getData();
            %
            if numel(cutTimeVec) == 1
                cutTimeVec = [cutTimeVec(1) cutTimeVec(1)];
            end
            if numel(cutTimeVec) ~= 2
                throwerror(['Reach:cut:input vector should ',...
                    'contain 1 or 2 elements']);
            end
            nTuples = self.getNElems();
            s0 = cutTimeVec(1);
            s1 = cutTimeVec(2);
            if s0 > s1
                throwerror('Reach:cut:s0 must be LEQ than s1');
            end
            for iTuple = 1 : nTuples
                timeVec = SData.timeVec{iTuple};
                t0 = timeVec(1);
                t1 = timeVec(end);
                if s0 < t0 || s0 > t1 || s1 < t0 || s1 > t1
                    throwerror('Reach:cut:wrong input format');
                end
                indLower = timeVec < s0;
                indGreater = timeVec > s1;
                if cutTimeVec(1) == cutTimeVec(2)
                    indClosest = find(indLower, 1, 'last');
                    indNewTimeVec = false(size(indLower));
                    indNewTimeVec(indClosest) = true;
                else
                    indNewTimeVec = ~ (indLower | indGreater);
                end
                newTimeVec = SData.timeVec{iTuple}(indNewTimeVec);
                % s0 ans s1 may not be in timeVec
                newS0 = newTimeVec(1);
                newS1 = newTimeVec(end);
                sTime = SData.sTime(iTuple);
                if newS0 <= sTime && sTime <= newS1
                    newSTime = sTime;
                    newIndSTime = find(newTimeVec == newSTime, 1);
                else
                    newSTime = newTimeVec(1);
                    newIndSTime = 1;
                end
                SData.timeVec{iTuple} = newTimeVec;
                SData.sTime(iTuple) = newSTime;
                SData.indSTime(iTuple) = newIndSTime;
                SData.QArray{iTuple} =...
                    SData.QArray{iTuple}(:, :, indNewTimeVec);
                SData.aMat{iTuple} =...
                    SData.aMat{iTuple}(:, indNewTimeVec);
                SData.MArray{iTuple} =...
                SData.MArray{iTuple}(:, :, indNewTimeVec);
                SData.ltGoodDirMat{iTuple} =...
                    SData.ltGoodDirMat{iTuple}(:, indNewTimeVec);
                SData.lsGoodDirVec{iTuple} =...
                    SData.ltGoodDirMat{iTuple}(:, newIndSTime);
                SData.ltGoodDirNormVec{iTuple} =...
                    SData.ltGoodDirNormVec{iTuple}(indNewTimeVec);
                SData.lsGoodDirNorm(iTuple) =...
                    SData.ltGoodDirNormVec{iTuple}(newIndSTime);
                SData.xTouchCurveMat{iTuple} =...
                    SData.xTouchCurveMat{iTuple}(:, indNewTimeVec);
                SData.xsTouchVec{iTuple} =...
                    SData.xTouchCurveMat{iTuple}(:, newIndSTime);
                SData.xTouchOpCurveMat{iTuple} =...
                    SData.xTouchOpCurveMat{iTuple}(:, indNewTimeVec);
                SData.xsTouchOpVec{iTuple} =...
                    SData.xTouchOpCurveMat{iTuple}(:, newIndSTime);
            end
            cutEllTubeRel = ...
                gras.ellapx.smartdb.rels.EllTube.fromStructList(...
                'gras.ellapx.smartdb.rels.EllTube', {SData});
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