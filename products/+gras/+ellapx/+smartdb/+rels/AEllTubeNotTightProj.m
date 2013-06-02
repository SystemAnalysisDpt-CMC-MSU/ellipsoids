classdef AEllTubeNotTightProj < ...
        gras.ellapx.smartdb.rels.IEllTubeNotTightProj
    %
    properties (Constant,Hidden)
        FCODE_PROJ_S_MAT
        FCODE_PROJ_TYPE
        FCODE_LT_GOOD_DIR_NORM_ORIG_VEC
        FCODE_LS_GOOD_DIR_NORM_ORIG
        FCODE_LS_GOOD_DIR_ORIG_VEC
    end
    %
    properties (Constant,Access=protected)
        N_SPOINTS=90
        REACH_TUBE_PREFIX='Reach'
        REG_TUBE_PREFIX='Reg'
    end
    %
    methods
        function namePrefix=getReachTubeNamePrefix(self)
            % GETREACHTUBEANEPREFIX - return prefix of the reach tube
            %
            % Input:
            %   regular:
            %      self.
            namePrefix=self.REACH_TUBE_PREFIX;
        end
        %
        function namePrefix=getRegTubeNamePrefix(self)
            % GETREGTUBEANEPREFIX - return prefix of the reg tube
            %
            % Input:
            %   regular:
            %      self.
            namePrefix=self.REG_TUBE_PREFIX;
        end
    end
    %
    methods
        function plObj=plot(self,varargin)
            % PLOT - displays ellipsoidal tubes using the specified RelationDataPlotter
            %
            % Input:
            %   regular:
            %       self:
            %   optional:
            %       plObj: smartdb.disp.RelationDataPlotter[1,1] - plotter object used
            %           for displaying ellipsoidal tubes
            %   properties:
            %       fGetTubeColor: function_handle[1,1] - function with the following
            %             signature:
            %           Input:
            %               regular:
            %                   apxType: gras.ellapx.enums.EApproxType[1,1]
            %                       - approximation type
            %           Output:
            %               patchColor: double[1,3] - RGB color vector
            %               patchAlpha: double[1,1] - transparency level
            %                   within [0,1] range
            %           if not specified, an internal function getPatchColorByApxType
            %               is used.
            % Output:
            %   plObj: smartdb.disp.RelationDataPlotter[1,1] - plotter
            %           object used for displaying ellipsoidal tubes
            %
            % $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2013-01-06 $
            % $Copyright: Moscow State University,
            %            Faculty of Computational Mathematics and Computer Science,
            %            System Analysis Department 2011 $
            %
            import modgen.logging.log4j.Log4jConfigurator
            import modgen.common.parseparext
            %
            [reg,isRegSpec,fGetPatchColor]=parseparext(varargin,...
                {'fGetTubeColor';@self.getPatchColorByApxType;'isfunction(x)'},...
                [0 1],...
                'regCheckList',...
                {@(x)isa(x,'smartdb.disp.RelationDataPlotter')},...
                'regDefList',cell(1,1));
            %
            if self.getNTuples()>0
                if ~isRegSpec
                    plObj=smartdb.disp.RelationDataPlotter;
                else
                    plObj=reg{1};
                end
                %
                fGetReachGroupKey=@(varargin)self.figureGetNamedGroupKeyFunc('reachTube',varargin{:});
                fGetRegGroupKey=@(varargin)self.figureGetNamedGroupKeyFunc('regTube',varargin{:});
                fSetReachFigProp=@(varargin)self.figureNamedSetPropFunc('reachTube',varargin{:});
                fSetRegFigProp=@(varargin)self.figureNamedSetPropFunc('regTube',varargin{:});
                fGetTubeAxisKey=@self.axesGetKeyTubeFunc;
                fGetCurveAxisKey=@self.axesGetKeyGoodCurveFunc;
                fSetTubeAxisProp=@self.axesSetPropTubeFunc;
                fSetCurveAxisProp=@self.axesSetPropGoodCurveFunc;
                fSetRegTubeAxisProp=@self.axesSetPropRegTubeFunc;
                fPlotReachTube=@(varargin)self.plotCreateReachTubeFunc(fGetPatchColor,varargin{:});
                fPlotRegTube=@self.plotCreateRegTubeFunc;
                fPlotCurve=@self.plotCreateGoodDirFunc;
                %
                isEmptyRegVec=cellfun(@(x)all(x(:)==0),self.MArray);
                %
                plotInternal(isEmptyRegVec,false);
                plotInternal(~isEmptyRegVec,true);
            else
                logger=Log4jConfigurator.getLogger();
                logger.warn('nTuples=0, there is nothing to plot');
            end
            %
            function plotInternal(isTupleVec,isRegPlot)
                import gras.ellapx.smartdb.F
                %
                if all(isTupleVec)
                    rel=self;
                else
                    rel=self.getTuples(isTupleVec);
                end
                fGetGroupKeyList={fGetReachGroupKey,fGetReachGroupKey};
                fSetFigPropList={fSetReachFigProp,fSetReachFigProp};
                fGetAxisKeyList={fGetTubeAxisKey,fGetCurveAxisKey};
                fSetAxiPropList={fSetTubeAxisProp,fSetCurveAxisProp};
                fPlotList={fPlotReachTube,fPlotCurve};
                if isRegPlot
                    fGetGroupKeyList=[fGetGroupKeyList,{fGetRegGroupKey}];
                    fSetFigPropList=[fSetFigPropList,{fSetRegFigProp}];
                    fGetAxisKeyList=[fGetAxisKeyList,{fGetTubeAxisKey}];
                    fSetAxiPropList=[fSetAxiPropList,{fSetRegTubeAxisProp}];
                    fPlotList=[fPlotList,{fPlotRegTube}];
                end
                plObj.plotGeneric(rel,...
                    fGetGroupKeyList,...
                    {'projType','projSTimeMat','sTime','lsGoodDirOrigVec'},...
                    fSetFigPropList,...
                    {'projType','projSTimeMat','sTime'},...
                    fGetAxisKeyList,...
                    {'projType','projSTimeMat'},...
                    fSetAxiPropList,...
                    {'projSTimeMat'},...
                    fPlotList,...
                    self.getPlotArgumentsFieldList());
            end
        end
    end
    %
    methods(Access=protected)
        function fieldList=getPlotArgumentsFieldList(self)
            import gras.ellapx.smartdb.F
            %
            FIELDS={'PROJ_TYPE','TIME_VEC','LS_GOOD_DIR_ORIG_VEC',...
                'LT_GOOD_DIR_MAT','S_TIME','LT_GOOD_DIR_NORM_VEC',...
                'LT_GOOD_DIR_NORM_ORIG_VEC','APPROX_TYPE','Q_ARRAY',...
                'A_MAT','M_ARRAY'};
            %
            fieldList=F.getNameList(FIELDS);
        end
        %
        function dependencyFieldList=getTouchCurveDependencyFieldList(~)
            dependencyFieldList={'sTime','lsGoodDirOrigVec',...
                'projType','projSTimeMat','MArray'};
        end
        %
        function figureGroupKeyName=figureGetGroupKeyFunc(self,projType,...
                projSTimeMat,sTime,varargin)
            import gras.ellapx.enums.EProjType;
            %
            figureGroupKeyName=self.figureGetNamedGroupKeyFunc('',...
                projType,projSTimeMat,sTime,varargin{:});
        end
        %
        function figureSetPropFunc(self,hFigure,figName,indGroup,...
                projType,projSTimeMat,sTime,varargin)
            self.figureNamedSetPropFunc('',hFigure,figName,indGroup,...
                projType,projSTimeMat,sTime,varargin{:});
        end
        %
        function scaleAxesHeight(~,hAxes,scaleFactor,isShift)
            isScaled=get(hAxes,'UserData');
            if isempty(isScaled)||~isScaled
                posVec=get(hAxes,'Position');
                newPosVec=posVec+...
                    [0 -(scaleFactor-1)*posVec(4)*isShift 0 ...
                    (scaleFactor-1)*posVec(4)];
                set(hAxes,'Position',newPosVec);
                set(hAxes,'UserData',true);
            end
        end
        %
        function resStr=projSpecVec2Str(~,projSTimeMat)
            resStr=['[',modgen.string.catwithsep(...
                cellfun(@(x)sprintf('x_%d',x),num2cell(...
                find(projSTimeMat)),'UniformOutput',false),','),']'];
        end
        %
        function axesName=axesGetKeyTubeFunc(self,~,projSTimeMat,varargin)
            axesName=['Ellipsoidal tubes, proj. on subspace ',...
                self.projSpecVec2Str(projSTimeMat)];
        end
        %
        function axesName=axesGetKeyGoodCurveFunc(self,~,projSTimeMat,varargin)
            axesName=['Good directions: proj. on subspace ',...
                self.projSpecVec2Str(projSTimeMat)];
        end
        %
        function hVec=axesSetPropBasicFunc(~,hAxes,axesName,projSTimeMat,varargin)
            import modgen.common.type.simple.checkgen;
            import gras.ellapx.smartdb.RelDispConfigurator;
            import modgen.graphics.camlight;
            %
            title(hAxes,axesName);
            checkgen(projSTimeMat,@(x)size(x,1)==2);
            indDimVec=find(sum(projSTimeMat));
            yLabel=sprintf('x_%d',indDimVec(1));
            zLabel=sprintf('x_%d',indDimVec(2));
            xLabel='time';
            %
            set(hAxes,'XLabel',...
                text('String',xLabel,'Interpreter','tex','Parent',hAxes));
            set(hAxes,'YLabel',...
                text('String',yLabel,'Interpreter','tex','Parent',hAxes));
            set(hAxes,'ZLabel',...
                text('String',zLabel,'Interpreter','tex','Parent',hAxes));
            viewAngleVec=RelDispConfigurator.getViewAngleVec();
            view(hAxes,viewAngleVec);
            set(hAxes,'xtickmode','auto',...
                'ytickmode','auto',...
                'ztickmode','auto','xgrid','on','ygrid','on','zgrid','on');
            hVec=[];
            %
            lightTypeList={{'left'},{40,65},{-20,25}};
            hLightVec=cellfun(@(x)camlight(hAxes,x{:}),lightTypeList);
            hVec=[hVec,hLightVec];
        end
        %
        function hVec=axesSetPropGoodCurveFunc(self,hAxes,axesName,...
                projSTimeMat,varargin)
            import modgen.common.type.simple.checkgen;
            import gras.ellapx.smartdb.RelDispConfigurator;
            %
            self.scaleAxesHeight(hAxes,0.9,false);
            %
            ylim(hAxes,[-1 1]);
            zlim(hAxes,[-1 1]);
            set(hAxes,'PlotBoxAspectRatio',[6 1 1]);
            hVec=self.axesSetPropBasicFunc(hAxes,axesName,projSTimeMat,varargin{:});
        end
        %
        function hVec=axesSetPropTubeFunc(self,hAxes,axesName,projSTimeMat,varargin)
            import modgen.common.type.simple.checkgen;
            import gras.ellapx.smartdb.RelDispConfigurator;
            %
            self.scaleAxesHeight(hAxes,1.1,true);
            axis(hAxes,'auto');
            hVec=self.axesSetPropBasicFunc(hAxes,axesName,projSTimeMat,varargin{:});
        end
        %
        function hVec=axesSetPropRegTubeFunc(self,hAxes,axesName,projSTimeMat,varargin)
            import modgen.common.type.simple.checkgen;
            import gras.ellapx.smartdb.RelDispConfigurator;
            %
            set(hAxes,'PlotBoxAspectRatio',[3 1 1]);
            hVec=self.axesSetPropBasicFunc(hAxes,axesName,projSTimeMat,varargin{:});
        end
        %
        function figureGroupKeyName=figureGetNamedGroupKeyFunc(self,...
                groupName,projType,projSTimeMat,sTime,...
                lsGoodDirOrigVec,varargin)
            import gras.ellapx.enums.EProjType;
            import gras.ellapx.smartdb.RelDispConfigurator;
            %
            isGoodCurvesSeparately=...
                RelDispConfigurator.getIsGoodCurvesSeparately();
            figureGroupKeyName=[groupName,'_',lower(char(projType)),...
                '_sp',self.projSpecVec2Str(projSTimeMat),'_st',...
                num2str(sTime)];
            if isGoodCurvesSeparately
                goodCurveStr=self.goodDirProp2Str(lsGoodDirOrigVec,sTime);
                figureGroupKeyName=[figureGroupKeyName,', ',goodCurveStr];
            end
        end
        
        %
        function figureNamedSetPropFunc(~,~,hFigure,...
                figureGroupName,indGroup,...
                ~,~,~,varargin)
            import gras.ellapx.enums.EProjType;
            %
            modgen.common.type.simple.checkgen(indGroup,'x==1');
            %
            set(hFigure,'NumberTitle','off','WindowStyle','docked',...
                'RendererMode','manual','Renderer','OpenGL','Name',...
                figureGroupName,'PaperPositionMode','auto');
        end
        %
        function [cMat,cOpMat]=getGoodDirColor(~,ltGoodDirNormVec,...
                ltGoodDirNormOrigVec)
            %
            ONE_NORM_COLOR_RGB_VEC=[1 0 0];%RED
            ZERO_NORM_COLOR_RGB_VEC=[1 1 0];%YELLOW
            normRatioVec=ltGoodDirNormVec./ltGoodDirNormOrigVec;
            nPoints=length(normRatioVec);
            cMat=repmat(ZERO_NORM_COLOR_RGB_VEC,nPoints,1)+...
                normRatioVec.'*(ONE_NORM_COLOR_RGB_VEC-...
                ZERO_NORM_COLOR_RGB_VEC);
            cOpMat=cMat;
        end
        %
        function [cMat,cOpMat]=getGoodCurveColor(self,varargin)
            [cMat,cOpMat]=self.getGoodDirColor(varargin{:});
        end
        %
        function [patchColor,patchAlpha]=getPatchColorByApxType(~,approxType)
            import gras.ellapx.enums.EApproxType;
            %
            switch approxType
                case EApproxType.Internal
                    patchColor=[0 1 0];
                    patchAlpha=0.5;
                case EApproxType.External
                    patchColor=[0 0 1];
                    patchAlpha=0.3;
                otherwise,
                    throwerror('wrongInput',...
                        'ApproxType=%s is not supported',char(approxType));
            end
        end
        %
        function [patchColor,patchAlpha]=getRegTubeColor(~,~)
            patchColor=[1 0 0];
            patchAlpha=1;
        end
        %
        function hVec=plotCreateGoodDirFunc(self,hAxes,~,timeVec,...
                lsGoodDirOrigVec,ltGoodDirMat,sTime,ltGoodDirNormVec,...
                ltGoodDirNormOrigVec,varargin)
            import gras.ellapx.enums.EProjType;
            %
            [cMat,cOpMat]=self.getGoodDirColor(ltGoodDirNormVec,...
                ltGoodDirNormOrigVec);
            %
            hVec(2)=dispDirCurve(ltGoodDirMat,lsGoodDirOrigVec,cMat);
            %
            hVec(1)=dispDirCurve(-ltGoodDirMat,-lsGoodDirOrigVec,cOpMat);
            axis(hAxes,'vis3d');
            %
            function hVec=dispDirCurve(ltGoodDirMat,lsGoodDirOrigVec,cMat)
                import modgen.graphics.plot3adv;
                %
                goodDirStr=self.goodDirProp2Str(lsGoodDirOrigVec,...
                    sTime);
                plotName=['Good directions curve: ',goodDirStr];
                vMat=ltGoodDirMat./repmat(ltGoodDirNormOrigVec,2,1);
                hVec=plot3adv(timeVec.',vMat(1,:).',vMat(2,:).',cMat,...
                    'lineWidth',2,'Parent',hAxes,'DisplayName',plotName);
            end
        end
        %
        function hVec=plotCreateGenericTubeFunc(self,hAxes,timeVec,...
                lsGoodDirOrigVec,sTime,approxType,QArray,aMat,...
                fGetPatchColor,tubeNamePrefix)
            %
            nSPoints=self.N_SPOINTS;
            goodDirStr=self.goodDirProp2Str(lsGoodDirOrigVec,sTime);
            patchName=sprintf('%s Tube, %s: %s',tubeNamePrefix,...
                char(approxType),goodDirStr);
            [vMat,fMat]=gras.geom.tri.elltubetri(...
                QArray,aMat,timeVec,nSPoints);
            nTimePoints=length(timeVec);
            [patchColor,patchAlpha]=fGetPatchColor(approxType);
            if nTimePoints==1
                nVerts=size(vMat,1);
                indVertVec=[1:nVerts,1];
                hVec=line('Parent',hAxes,'xData',vMat(indVertVec,1),...
                    'yData',vMat(indVertVec,2),...
                    'zData',vMat(indVertVec,3),'Color',patchColor);
            else
                hVec=patch('FaceColor','interp','EdgeColor','none',...
                    'DisplayName',patchName,...
                    'FaceAlpha',patchAlpha,...
                    'FaceVertexCData',repmat(patchColor,size(vMat,1),1),...
                    'Faces',fMat,'Vertices',vMat,'Parent',hAxes,...
                    'EdgeLighting','phong','FaceLighting','phong');
                material('metal');
            end
            hold(hAxes,'on');
        end
        %
        function hVec=plotCreateReachTubeFunc(self,fGetPatchColor,...
                hAxes,projType,timeVec,lsGoodDirOrigVec,ltGoodDirMat,...
                sTime,ltGoodDirNormVec,ltGoodDirNormOrigVec,approxType,...
                QArray,aMat,MArray,varargin)
            import gras.ellapx.enums.EApproxType;
            %
            hVec=self.plotCreateGenericTubeFunc(hAxes,timeVec,...
                lsGoodDirOrigVec,sTime,approxType,QArray,aMat,...
                fGetPatchColor,self.REACH_TUBE_PREFIX);
            axis(hAxes,'tight');
            axis(hAxes,'normal');
            if approxType==EApproxType.Internal
                hAddVec=plotCreateRegTubeFunc(self,hAxes,projType,...
                    timeVec,lsGoodDirOrigVec,ltGoodDirMat,sTime,...
                    ltGoodDirNormVec,ltGoodDirNormOrigVec,approxType,...
                    QArray,aMat,MArray,varargin{:});
                hVec=[hVec,hAddVec];
            end
        end
        %
        function hVec=plotCreateRegTubeFunc(self,~,timeVec,...
                lsGoodDirOrigVec,~,sTime,~,~,approxType,~,aMat,MArray,...
                varargin)
            %
            import gras.ellapx.enums.EApproxType;
            %
            if approxType==EApproxType.Internal
                fGetPatchColor=@self.getRegTubeColor;
                hVec=self.plotCreateGenericTubeFunc(hAxes,...
                    timeVec,lsGoodDirOrigVec,sTime,...
                    approxType,MArray,zeros(size(aMat)),...
                    fGetPatchColor,self.REG_TUBE_PREFIX);
            else
                hVec=[];
            end
        end
        
        %
        function checkDataConsistency(self)
            import modgen.common.throwerror;
            import gras.gen.SquareMatVector;
            %
            TS_CHECK_TOL=1e-13;
            %
            if self.getNTuples()>0
                %
                % check ls and lt consistency
                %
                fCheck=@(x,y,z)max(abs(x-y(z)))<=TS_CHECK_TOL;
                indSTime=num2cell(self.indSTime);
                self.checkSVsTConsistency(num2cell(self.lsGoodDirNormOrig),...
                    self.ltGoodDirNormOrigVec,indSTime,'lsGoodDirNormOrig',...
                    'ltGoodDirNormOrigVec',fCheck);
                nInd=length(self.projSTimeMat);
                compareLsGoodDirVec=cell(nInd,1);
                indList=cell(nInd,1);
                for iInd=1:nInd
                    compareLsGoodDirVec{iInd}=self.projSTimeMat{iInd}*self.lsGoodDirOrigVec{iInd};
                    indList{iInd}=1:size(self.projSTimeMat{iInd},1);
                end
                self.checkSVsTConsistency(self.lsGoodDirVec,...
                    compareLsGoodDirVec,indList,...
                    'lsGoodDirVec','lsGoodDirOrigVec',fCheck);
                %
                % check general consistency
                %
                checkFieldList={'dim',...
                    'projSTimeMat','projType','ltGoodDirNormOrigVec',...
                    'lsGoodDirNormOrig','lsGoodDirOrigVec','timeVec'};
                %
                [isOkList,errTagList,reasonList]=...
                    self.applyTupleGetFunc(@checkTuple,checkFieldList,...
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
            end
            %
            function [isOk,errTagStr,reasonStr]=checkTuple(dim,...
                    projSTimeMat,projType,ltGoodDirNormOrigVec,...
                    lsGoodDirNormOrig,lsGoodDirOrigVec,timeVec)
                errTagStr='';
                import modgen.common.type.simple.lib.*;
                reasonStr='';
                nDims=dim;
                nFDims=length(lsGoodDirOrigVec);
                nPoints=length(timeVec);
                isOk=ismatrix(projSTimeMat)&&size(projSTimeMat,2)==nFDims&&...
                    numel(projType)==1&&...
                    isrow(ltGoodDirNormOrigVec)&&...
                    numel(ltGoodDirNormOrigVec)==nPoints&&...
                    iscol(lsGoodDirOrigVec)&&...
                    numel(lsGoodDirNormOrig)==1&&...
                    size(projSTimeMat,1)==nDims;
                if ~isOk
                    reasonStr='Fields have inconsistent sizes';
                    errTagStr='badSize';
                end
            end
        end
    end
end