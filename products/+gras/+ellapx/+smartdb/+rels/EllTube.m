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